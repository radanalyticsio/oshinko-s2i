#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common
source $TEST_DIR/incomplete_image/common

$TEST_DIR/resources/sparkinputs.sh

RESOURCE_DIR=$TEST_DIR/resources

os::test::junit::declare_suite_start "install_spark"

if [ 1 -eq 2 ]; then
echo "++ build_md5"
build_md5 pyspark-inc $S2I_TEST_IMAGE_PYSPARK

echo "++ build_md5 (md5 deleted)"
md5=$(find $RESOURCE_DIR/spark-inputs -name "*.md5")
rm $md5
skip_app=true
build_md5 pyspark-inc $S2I_TEST_IMAGE_PYSPARK

echo "++ build_bad_md5"
mv $RESOURCE_DIR/spark-inputs/$(basename $md5 .md5).bad $md5
build_bad_md5 pyspark-inc $S2I_TEST_IMAGE_PYSPARK
rm $md5

echo "++ build_from_directory"
build_from_directory pyspark-inc $S2I_TEST_IMAGE_PYSPARK

echo "++ tarball_no_submit"
tarball_no_submit pyspark-inc $S2I_TEST_IMAGE_PYSPARK

echo "++ directory_no_submit"
directory_no_submit pyspark-inc $S2I_TEST_IMAGE_PYSPARK

echo "++ build_bad_tarball"
build_bad_tarball pyspark-inc $S2I_TEST_IMAGE_PYSPARK

echo "++ build_env_var"
build_env_var pyspark-inc $S2I_TEST_IMAGE_PYSPARK
fi

echo "++ already_installed"
already_installed pyspark-inc $S2I_TEST_IMAGE_PYSPARK

echo "++ bad_submit"
bad_submit pyspark-inc $S2I_TEST_IMAGE_PYSPARK

echo "++ copy_nocopy"
copy_nocopy pyspark-inc $S2I_TEST_IMAGE_PYSPARK

#cleanup_app

os::test::junit::declare_suite_end
