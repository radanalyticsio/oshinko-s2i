#!/bin/bash

function usage() {
    echo "usage: get-rad-image.sh [-hf]"
    echo
    echo "Download the rad-image script from https://radanalytics.io and modify it to support the optional R image"
    echo
    echo "Options:"
    echo "  -h      Print this help message"
    echo "  -f      Force download and overwrite of rad-image"
}

FORCE=false
while getopts fh option; do
    case $option in
        h)
            usage
            exit 0
            ;;
        f)
            FORCE=true
            ;;
        *)
            ;;
    esac
done
shift $((OPTIND-1))

if [ -f rad-image ]; then
    if [ "$FORCE" == "true" ]; then
        rm rad-image
    else
        echo rad-image is already downloaded, exiting
        exit 0
    fi
fi

wget https://radanalytics.io/assets/tools/rad-image

# Change the IMAGESTREAMS variable to include R
IS=$(grep "IMAGESTREAMS=" rad-image)
if ! [[ "$IS" = *"radanalytics-r-spark"* ]]; then
    echo Adding R image to supported images
    sed -i 's/IMAGESTREAMS="/IMAGESTREAMS="radanalytics-r-spark /' rad-image
fi
chmod +x rad-image
