#/bin/bash
set -ex
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
if [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        if ! [ -x "$(greadlink -f `dirname "$0"`)" ]; then
          'Error: coreutils is not installed.' >&2
          exit 1
        fi
        TOP_DIR=$(greadlink -f `dirname "$0"` | grep -o '.*/oshinko-s2i')
        mkdir -p $TOP_DIR/release_templates
        rm -rf $TOP_DIR/release_templates/*

        cp $TOP_DIR/templates/*.json $TOP_DIR/release_templates

        gsed -r -i "s@(radanalyticsio/radanalytics-.*spark)\"@\1:$1\"@" $TOP_DIR/release_templates/*
else
        TOP_DIR=$(readlink -f `dirname "$0"` | grep -o '.*/oshinko-s2i')
        mkdir -p $TOP_DIR/release_templates
        rm -rf $TOP_DIR/release_templates/*

        cp $TOP_DIR/templates/*.json $TOP_DIR/release_templates

        sed -r -i "s@(radanalyticsio/radanalytics-.*spark)\"@\1:$1\"@" $TOP_DIR/release_templates/*
fi
echo "Successfully wrote templates to release_templates/ with version tag $1"
echo
echo "grep radanalyticsio/radanalytics-.*spark:$1 *"
echo
cd $TOP_DIR/; grep radanalyticsio/radanalytics-.*spark:$1 release_templates/*

echo
echo tar -czf oshinko_s2i_$1.tar.gz release_templates
tar -czf oshinko_s2i_$1.tar.gz release_templates
