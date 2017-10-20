#/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: release-templates.sh VERSION-TAG"
    exit 1
fi

TOP_DIR=$(readlink -f `dirname "$0"` | grep -o '.*/oshinko-s2i')
mkdir -p $TOP_DIR/release_templates
rm -rf $TOP_DIR/release_templates/*

cp $TOP_DIR/templates/*.json $TOP_DIR/release_templates

sed -r -i "s@(radanalyticsio/radanalytics-.*spark)\"@\1:$1\"@" $TOP_DIR/release_templates/*

echo "Successfully wrote templates to release_templates/ with version tag $1"
echo
echo "grep radanalyticsio/radanalytics-.*spark:$1 *"
echo
cd $TOP_DIR/; grep radanalyticsio/radanalytics-.*spark:$1 release_templates/*
