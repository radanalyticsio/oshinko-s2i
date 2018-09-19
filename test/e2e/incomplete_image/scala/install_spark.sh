#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common
source $TEST_DIR/incomplete_image/common

$TEST_DIR/resources/sparkinputs.sh

RESOURCE_DIR=$TEST_DIR/resources

SCALATEMP_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i')/templates

# Set up a template to read our incomplete image
cp  $SCALATEMP_DIR/scalabuilddc.json $RESOURCE_DIR/scalabuilddc.json
fix_template $RESOURCE_DIR/scalabuilddc.json radanalyticsio/radanalytics-scala-spark $S2I_TEST_IMAGE_SCALA_INC

# Set up a template to read from an imagestream for our completed image
cp  $SCALATEMP_DIR/scalabuilddc.json $RESOURCE_DIR/scalabuilddc-is.json
fix_template_for_imagestream $RESOURCE_DIR/scalabuilddc-is.json radanalyticsio/radanalytics-scala-spark scala-inc:latest

os::test::junit::declare_suite_start "install_spark"

echo "++ build_md5"
build_md5 scala-inc $S2I_TEST_IMAGE_SCALA_INC

# if our md5 build worked, we have a completed image stream so try
# a basic app with it
echo "++ run_completed_app"
run_completed_app $RESOURCE_DIR/scalabuilddc-is.json https://github.com/radanalyticsio/s2i-integration-test-apps

echo "++ build_md5 (md5 deleted)"
md5=$(find $RESOURCE_DIR/spark-inputs -name "*.md5")
rm $md5
skip_app=true
build_md5 scala-inc $S2I_TEST_IMAGE_SCALA_INC

echo "++ build_bad_md5"
mv $RESOURCE_DIR/spark-inputs/$(basename $md5 .md5).bad $md5
build_bad_md5 scala-inc $S2I_TEST_IMAGE_SCALA_INC
rm $md5

echo "++ build_from_directory"
build_from_directory scala-inc $S2I_TEST_IMAGE_SCALA_INC

echo "++ tarball_no_submit"
tarball_no_submit scala-inc $S2I_TEST_IMAGE_SCALA_INC

echo "++ directory_no_submit"
directory_no_submit scala-inc $S2I_TEST_IMAGE_SCALA_INC

echo "++ build_bad_tarball"
build_bad_tarball scala-inc $S2I_TEST_IMAGE_SCALA_INC

echo "++ build_env_var"
build_env_var scala-inc $S2I_TEST_IMAGE_SCALA_INC

echo "++ already_installed"
already_installed scala-inc $S2I_TEST_IMAGE_SCALA_INC

echo "++ bad_submit"
bad_submit scala-inc $S2I_TEST_IMAGE_SCALA_INC

echo "++ copy_nocopy"
copy_nocopy scala-inc $S2I_TEST_IMAGE_SCALA_INC

echo "++ run_incomplete_app"
run_incomplete_app $RESOURCE_DIR/scalabuilddc.json https://github.com/radanalyticsio/s2i-integration-test-apps

os::test::junit::declare_suite_end
