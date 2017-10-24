#!/bin/bash

# Check for any tar.gz or .tgz files in the image build directories.
# The file list is passed through stdin.

found=0
if [ "$#" -ne 0 ]; then
    top=$1
else
    top=
fi
while read f
do
    if [[ "$f" =~ (pyspark|scala|java)-build/.*\.(tar\.gz|tgz) ]]; then
        if [ -s "$top/$f" ]; then
            echo $f is not zero length
            found=1
        fi
    fi
done
exit $found
