#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common
source $TEST_DIR/incomplete_image/common

$TEST_DIR/resources/sparkinputs.sh

RESOURCE_DIR=$TEST_DIR/resources

JAVATEMP_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i')/templates

# Set up a template to read our incomplete image
cp  $JAVATEMP_DIR/javabuilddc.json $RESOURCE_DIR/javabuilddc.json
fix_template $RESOURCE_DIR/javabuilddc.json radanalyticsio/radanalytics-java-spark $S2I_TEST_IMAGE_JAVA_INC

# Set up a template to read from an imagestream for our completed image
cp  $JAVATEMP_DIR/javabuilddc.json $RESOURCE_DIR/javabuilddc-is.json
fix_template_for_imagestream $RESOURCE_DIR/javabuilddc-is.json radanalyticsio/radanalytics-java-spark java-inc:latest

set_worker_count $S2I_TEST_WORKERS

os::test::junit::declare_suite_start "install_spark"

echo "++ build_md5"
build_md5 java-inc $S2I_TEST_IMAGE_JAVA_INC

# if our md5 build worked, we have a completed image stream so try
# a basic app with it
echo "++ run_completed_app"
run_completed_app $RESOURCE_DIR/javabuilddc-is.json https://github.com/radanalyticsio/s2i-integration-test-apps clusterconfig

echo "++ build_md5 (md5 deleted)"
md5=$(find $RESOURCE_DIR/spark-inputs -name "*.md5")
rm $md5
skip_app=true
build_md5 java-inc $S2I_TEST_IMAGE_JAVA_INC

echo "++ build_bad_md5"
mv $RESOURCE_DIR/spark-inputs/$(basename $md5 .md5).bad $md5
build_bad_md5 java-inc $S2I_TEST_IMAGE_JAVA_INC
rm $md5

echo "++ build_from_directory"
build_from_directory java-inc $S2I_TEST_IMAGE_JAVA_INC

echo "++ tarball_no_submit"
tarball_no_submit java-inc $S2I_TEST_IMAGE_JAVA_INC

echo "++ directory_no_submit"
directory_no_submit java-inc $S2I_TEST_IMAGE_JAVA_INC

echo "++ build_bad_tarball"
build_bad_tarball java-inc $S2I_TEST_IMAGE_JAVA_INC

echo "++ build_env_var"
build_env_var java-inc $S2I_TEST_IMAGE_JAVA_INC

echo "++ already_installed"
already_installed java-inc $S2I_TEST_IMAGE_JAVA_INC

echo "++ bad_submit"
bad_submit java-inc $S2I_TEST_IMAGE_JAVA_INC

echo "++ run_incomplete_app"
run_incomplete_app $RESOURCE_DIR/javabuilddc.json https://github.com/radanalyticsio/s2i-integration-test-apps

os::test::junit::declare_suite_end
