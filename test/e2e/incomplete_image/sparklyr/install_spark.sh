#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common
source $TEST_DIR/incomplete_image/common

$TEST_DIR/resources/sparkinputs.sh

SPARKLYR_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i')/templates
RESOURCE_DIR=$TEST_DIR/resources

# Set up a template to read our incomplete image
cp  $SPARKLYR_DIR/sparklyrbuilddc.json $RESOURCE_DIR/sparklyrbuilddc.json
fix_template $RESOURCE_DIR/sparklyrbuilddc.json radanalyticsio/radanalytics-r-spark $S2I_TEST_IMAGE_SPARKLYR_INC

# Set up a template to read from an imagestream for our completed image
cp  $SPARKLYR_DIR/sparklyrbuilddc.json $RESOURCE_DIR/sparklyrbuilddc-is.json
fix_template_for_imagestream $RESOURCE_DIR/sparklyrbuilddc-is.json radanalyticsio/radanalytics-r-spark sparklyr-inc:latest

os::test::junit::declare_suite_start "install_spark"

echo "++ build_md5"
build_md5 sparklyr-inc $S2I_TEST_IMAGE_SPARKLYR_INC

# if our md5 build worked, we have a completed image stream so try
# a basic app with it
echo "++ run_completed_app"
run_completed_app $RESOURCE_DIR/sparklyrbuilddc-is.json https://github.com/tmckayus/r-openshift-ex.git

echo "++ build_md5 (md5 deleted)"
md5=$(find $RESOURCE_DIR/spark-inputs -name "*.md5")
rm $md5
skip_app=true
build_md5 sparklyr-inc $S2I_TEST_IMAGE_SPARKLYR_INC

echo "++ build_bad_md5"
mv $RESOURCE_DIR/spark-inputs/$(basename $md5 .md5).bad $md5
build_bad_md5 sparklyr-inc $S2I_TEST_IMAGE_SPARKLYR_INC
rm $md5

echo "++ build_from_directory"
build_from_directory sparklyr-inc $S2I_TEST_IMAGE_SPARKLYR_INC

echo "++ tarball_no_submit"
tarball_no_submit sparklyr-inc $S2I_TEST_IMAGE_SPARKLYR_INC

echo "++ directory_no_submit"
directory_no_submit sparklyr-inc $S2I_TEST_IMAGE_SPARKLYR_INC

echo "++ build_bad_tarball"
build_bad_tarball sparklyr-inc $S2I_TEST_IMAGE_SPARKLYR_INC

echo "++ build_env_var"
build_env_var sparklyr-inc $S2I_TEST_IMAGE_SPARKLYR_INC

echo "++ already_installed"
already_installed sparklyr-inc $S2I_TEST_IMAGE_SPARKLYR_INC

echo "++ bad_submit"
bad_submit sparklyr-inc $S2I_TEST_IMAGE_SPARKLYR_INC

echo "++ copy_nocopy"
copy_nocopy sparklyr-inc $S2I_TEST_IMAGE_SPARKLYR_INC

echo "++ run_incomplete_app"
run_incomplete_app $RESOURCE_DIR/sparklyrbuilddc.json https://github.com/tmckayus/r-openshift-ex.git

os::test::junit::declare_suite_end
