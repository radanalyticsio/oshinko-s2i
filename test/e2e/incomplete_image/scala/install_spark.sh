#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common
source $TEST_DIR/incomplete_image/common

$TEST_DIR/resources/sparkinputs.sh

RESOURCE_DIR=$TEST_DIR/resources

os::test::junit::declare_suite_start "install_spark"

echo "++ build_md5"
build_md5 scala-inc $S2I_TEST_IMAGE_SCALA

echo "++ build_md5 (md5 deleted)"
md5=$(find $RESOURCE_DIR/spark-inputs -name "*.md5")
rm $md5
skip_app=true
build_md5 scala-inc $S2I_TEST_IMAGE_SCALA

echo "++ build_bad_md5"
mv $RESOURCE_DIR/spark-inputs/$(basename $md5 .md5).bad $md5
build_bad_md5 scala-inc $S2I_TEST_IMAGE_SCALA
rm $md5

echo "++ build_from_directory"
build_from_directory scala-inc $S2I_TEST_IMAGE_SCALA

echo "++ tarball_no_submit"
tarball_no_submit scala-inc $S2I_TEST_IMAGE_SCALA

echo "++ directory_no_submit"
directory_no_submit scala-inc $S2I_TEST_IMAGE_SCALA

echo "++ build_bad_tarball"
build_bad_tarball scala-inc $S2I_TEST_IMAGE_SCALA

echo "++ build_env_var"
build_env_var scala-inc $S2I_TEST_IMAGE_SCALA

echo "++ already_installed"
already_installed scala-inc $S2I_TEST_IMAGE_SCALA

echo "++ bad_submit"
bad_submit scala-inc $S2I_TEST_IMAGE_SCALA

echo "++ copy_nocopy"
copy_nocopy scala-inc $S2I_TEST_IMAGE_SCALA

#cleanup_app

os::test::junit::declare_suite_end