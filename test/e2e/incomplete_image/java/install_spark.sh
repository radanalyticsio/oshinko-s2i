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
build_md5 java-inc $S2I_TEST_IMAGE_JAVA

echo "++ build_md5 (md5 deleted)"
md5=$(find $RESOURCE_DIR/spark-inputs -name "*.md5")
rm $md5
skip_app=true
build_md5 java-inc $S2I_TEST_IMAGE_JAVA

echo "++ build_bad_md5"
mv $RESOURCE_DIR/spark-inputs/$(basename $md5 .md5).bad $md5
build_bad_md5 java-inc $S2I_TEST_IMAGE_JAVA
rm $md5

echo "++ build_from_directory"
build_from_directory java-inc $S2I_TEST_IMAGE_JAVA

echo "++ tarball_no_submit"
tarball_no_submit java-inc $S2I_TEST_IMAGE_JAVA

echo "++ directory_no_submit"
directory_no_submit java-inc $S2I_TEST_IMAGE_JAVA

echo "++ build_bad_tarball"
build_bad_tarball java-inc $S2I_TEST_IMAGE_JAVA

echo "++ build_env_var"
build_env_var java-inc $S2I_TEST_IMAGE_JAVA
fi

echo "++ already_installed"
already_installed java-inc $S2I_TEST_IMAGE_JAVA

echo "++ bad_submit"
bad_submit java-inc $S2I_TEST_IMAGE_JAVA

echo "++ copy_nocopy"
copy_nocopy java-inc $S2I_TEST_IMAGE_JAVA

#cleanup_app

os::test::junit::declare_suite_end
