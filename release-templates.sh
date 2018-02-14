#/bin/bash

if [ "$#" -ne 1 ]; then
    echo
    echo "Generates the s2i templtaes in the release_templates subdirectory"
    echo "with the image tags set to VERSION-TAG."
    echo
    echo "Creates a tarball suitable for an oshinko-s2i github release."
    echo
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

echo
echo tar -czf oshinko_s2i_$1.tar.gz release_templates
tar -czf oshinko_s2i_$1.tar.gz release_templates
