#!/bin/bash

function usage() {
    echo
    echo "Changes the image.*.yaml files and adds them to the current commit (git add)"
    echo "No change is made for any option not specified"
    echo
    echo "Usage: change-yaml.sh [options]"
    echo
    echo "optional arguments:"
    echo
    echo "  -o OSHINKO_VERSION  The oshinko version, like v0.4.4"
    echo
    echo "  -s SPARK_VERSION    The spark version, like 2.2.1"
    echo "                      This value is used to download the spark distribution, and for the"
    echo "                      scala image it's used to determine the openshift-spark base image"
    echo
    echo "  -h                  Show this message"
}

if [ "$#" -eq 0 ]; then
    echo No options specified, changing nothing.
    exit 0
fi

# Set the hadoop version
HVER=2.7

while getopts o:s:h opt; do
    case $opt in
        o)
            OVER=$OPTARG
            ;;
        s)
            SPARK=$OPTARG
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Change the oshinko version
if [ ! -z ${OVER+x} ]; then
    wget https://github.com/radanalyticsio/oshinko-cli/releases/download/${OVER}/oshinko_${OVER}_linux_amd64.tar.gz -O /tmp/oshinko_${OVER}_linux_amd64.tar.gz
    if [ "$?" -eq 0 ]; then

        sum=$(md5sum /tmp/oshinko_${OVER}_linux_amd64.tar.gz | cut -d ' ' -f 1)
        if [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
          # Fix the url references
          gsed -i "s@https://github.com/radanalyticsio/oshinko-cli/releases/download/.*@https://github.com/radanalyticsio/oshinko-cli/releases/download/${OVER}/oshinko_${OVER}_linux_amd64.tar.gz@" image.*.yaml
          # Fix the md5sum on the line following the url
          gsed -i '\@url: https://github.com/radanalyticsio/oshinko-cli/releases/download@!b;n;s/md5.*/md5: '$sum'/' image.*.yaml
        else
          sed -i "s@https://github.com/radanalyticsio/oshinko-cli/releases/download/.*@https://github.com/radanalyticsio/oshinko-cli/releases/download/${OVER}/oshinko_${OVER}_linux_amd64.tar.gz@" image.*.yaml
          # Fix the md5sum on the line following the url
          sed -i '\@url: https://github.com/radanalyticsio/oshinko-cli/releases/download@!b;n;s/md5.*/md5: '$sum'/' image.*.yaml
        fi
    else
        echo "Failed to get the md5 sum for the specified oshinko version, the version $OVER may not be a real version"
        exit 1
    fi
fi

# Change spark distro
if [ ! -z ${SPARK+x} ]; then

    # Change the md5sum for pyspark and java, update base image for scala
    wget https://archive.apache.org/dist/spark/spark-${SPARK}/spark-${SPARK}-bin-hadoop${HVER}.tgz.md5 -O /tmp/spark-${SPARK}-bin-hadoop${HVER}.tgz.md5
    if [ "$?" -eq 0 ]; then

        sum=$(cat /tmp/spark-${SPARK}-bin-hadoop2.7.tgz.md5 | cut -d':' -f 2 | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

	# Fix the url references
	sed -i "s@https://archive.apache.org/dist/spark/spark-.*/spark-.*-bin-@https://archive.apache.org/dist/spark/spark-${SPARK}/spark-${SPARK}-bin-@" image.*.yaml

	# Fix the md5 sum references on the line following the url
        sed -i '\@url: https://archive.apache.org/dist/spark/@!b;n;s/md5.*/md5: '$sum'/' image.*.yaml
    else
        echo "Failed to get the md5 sum for the specified spark version, the version $SPARK may not be a real version"
        exit 1
    fi
fi

# Add any changes for commit
git add image.*.yaml
