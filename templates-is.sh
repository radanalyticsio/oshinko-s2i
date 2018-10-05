#!/bin/bash

function usage() {
    echo "usage: templates-is.sh [-hf] [TAG]"
    echo
    echo "Copy s2i to ./templates-is and modify for use with imagestreams created with rad-image"
    echo
    echo "Options:"
    echo "  -h      Print this help message"
    echo "  -f      Force overwrite of ./templates-is"
    echo "  TAG     Use TAG as the tag for imagestream references. Default is 'complete'"
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

if [ "$#" -ne 1 ]; then
    tag=complete
else
    tag=$1
fi

if [ -d templates-is ]; then
    if [ "$FORCE" == "true" ]; then
        rm -rf templates-is/*
    else
        echo templates-is already exists, run with '-f' to overwrite
        exit 1
    fi
fi

mkdir -p templates-is
echo Using tag "'"$tag"'"
echo Generated:
templates=$(grep -l DockerImage templates/*.json)
for t in $templates; do
    echo "    "templates-is/$(basename $t)
    cp $t templates-is
    sed -i 's@"kind": "DockerImage"@"kind": "ImageStreamTag"@g' templates-is/$(basename $t)
    sed -i -r "s@\"name\": \"radanalyticsio/(.*)\"@\"name\": \"\1:"$tag"@g" templates-is/$(basename $t) 
done	

