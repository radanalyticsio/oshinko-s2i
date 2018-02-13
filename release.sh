#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Changes the oshinko CLI version used by the S2I images and regenerates the build directories"
    echo 'Commits the changes on a branch release_$NEW_VERSION, ready for a push'
    echo "Usage: release.sh NEW_VERSION"
    exit 1
fi

git checkout -b release_$1 

# Fix up the yaml files to hold the url for the new version of oshinko-cli
sed -i "s@https://github.com/radanalyticsio/oshinko-cli/releases/download/.*@https://github.com/radanalyticsio/oshinko-cli/releases/download/$1/oshinko_$1_linux_amd64.tar.gz@" image.*.yaml

# Get the tarball for the CLI so we can get the md5sum
wget https://github.com/radanalyticsio/oshinko-cli/releases/download/$1/oshinko_$1_linux_amd64.tar.gz -O oshinko_$1_linux_amd64.tar.gz
sum=$(md5sum oshinko_$1_linux_amd64.tar.gz | cut -d ' ' -f 1)

# Replace the md5sum for the tarball on the line following the url
sed -i '\@url: https://github.com/radanalyticsio/oshinko-cli/releases/download@!b;n;s/md5.*/md5: '$sum'/' image.*.yaml

rm -rf target
git rm pyspark-build/oshinko*.tar.gz
git rm java-build/oshinko*.tar.gz
git rm scala-build/oshinko*.tar.gz
make clean-context
make context
make zero-tarballs

git add pyspark-build/oshinko*.tar.gz
git add java-build/oshinko*.tar.gz
git add scala-build/oshinko*.tar.gz
git commit -a -m "Change oshinko CLI version to $1"
