#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

SCALATEMP_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i')/templates

SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
source $SCRIPT_DIR/../../builddc
source $SCRIPT_DIR/../../buildonly

RESOURCE_DIR=$TEST_DIR/resources
cp $SCALATEMP_DIR/scalabuild.json $RESOURCE_DIR/scalabuild.json
fix_template $RESOURCE_DIR/scalabuild.json radanalyticsio/radanalytics-scala-spark $S2I_TEST_IMAGE_SCALA
set_template $RESOURCE_DIR/scalabuild.json
set_git_uri https://github.com/radanalyticsio/s2i-integration-test-apps
set_fixed_app_name scala-build

set_worker_count $S2I_TEST_WORKERS

os::test::junit::declare_suite_start "$MY_SCRIPT"

echo "++ check_image"
check_image $S2I_TEST_IMAGE_SCALA

echo "++ build_test_no_app_name"
build_test_no_app_name

echo "++ test_no_source_or_image"
test_no_source_or_image

echo "++ build_test_app_file sparkpi_2.11-0.1.jar"
build_test_app_file sparkpi_2.11-0.1.jar

echo "++ test_git_ref"
test_git_ref $GIT_URI 6fa7763517d44a9f39d6b4f0a6c15737afbf2a5a

os::test::junit::declare_suite_end
