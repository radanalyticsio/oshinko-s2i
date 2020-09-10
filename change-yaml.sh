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
HVER=3.2

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

    # TODO remove this download when sha512 support lands in upstream cekit (tmckay)
    # Since this is big let's see if it's already there
    if [ -f "/tmp/spark-${SPARK}-bin-hadoop${HVER}.tgz" ]; then
        echo
        echo Using existing "/tmp/spark-${SPARK}-bin-hadoop${HVER}.tgz", if this is not what you want delete it and run again
        echo
    else
        wget https://archive.apache.org/dist/spark/spark-${SPARK}/spark-${SPARK}-bin-hadoop${HVER}.tgz -O /tmp/spark-${SPARK}-bin-hadoop${HVER}.tgz
        if [ "$?" -ne 0 ]; then
            echo "Failed to download the specified version Spark archive"
            exit 1
        fi
    fi

    wget https://archive.apache.org/dist/spark/spark-${SPARK}/spark-${SPARK}-bin-hadoop${HVER}.tgz.sha512 -O /tmp/spark-${SPARK}-bin-hadoop${HVER}.tgz.sha512
    if [ "$?" -ne 0 ]; then
        echo "Failed to download the sha512 sum for the specified Spark version"
        exit 1
    fi

    # TODO remove this checksum calculation when sha512 support lands in upstream cekit (tmckay)
    calcsum=$(sha512sum /tmp/spark-${SPARK}-bin-hadoop${HVER}.tgz | cut -d" "  -f1)
    sum=$(cat  /tmp/spark-${SPARK}-bin-hadoop${HVER}.tgz.sha512 | tr -d [:space:] | cut -d: -f2 | tr [:upper:] [:lower:])
    if [ "$calcsum" != "$sum" ]; then
        echo "Failed to confirm authenticity of Spark archive, checksum mismatch"
        echo "sha512sum   : ${calcsum}"
        echo ".sha512 file: ${sum}"
        exit 1
    fi

    if [[ "$OSTYPE" == "darwin"* ]]; then
	SED=gsed
    else
	SED=sed
    fi

    # Fix the url references
    $SED -i "s@https://archive.apache.org/dist/spark/spark-.*/spark-.*-bin-hadoop.*\.tgz@https://archive.apache.org/dist/spark/spark-${SPARK}/spark-${SPARK}-bin-hadoop${HVER}.tgz@" modules/spark/module.yaml

    # Fix the md5 sum references on the line following the url
    # TODO replace this with sha512 when it lands in upstream cekit (tmckay)
    calcsum=$(md5sum /tmp/spark-${SPARK}-bin-hadoop${HVER}.tgz | cut -d" " -f1)
    $SED -i '\@url: https://archive.apache.org/dist/spark/@!b;n;s/md5.*/md5: '$calcsum'/' modules/spark/module.yaml

    #change the spark version in the env var
    $SED -i '\@name: SPARK_VERSION@!b;n;s/value:.*/value: '$SPARK'/' image.java.yaml
fi

# Add any changes for commit
git add image.*.yaml
