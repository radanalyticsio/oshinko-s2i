#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
source $SCRIPT_DIR/../../builddc

SCALATEMP_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i')/templates
RESOURCE_DIR=$TEST_DIR/resources

cp  $SCALATEMP_DIR/scalabuilddc.json $RESOURCE_DIR/scalabuilddc.json
fix_template $RESOURCE_DIR/scalabuilddc.json radanalyticsio/radanalytics-scala-spark $S2I_TEST_IMAGE_SCALA
set_template $RESOURCE_DIR/scalabuilddc.json
set_git_uri https://github.com/radanalyticsio/s2i-integration-test-apps
set_worker_count 1
set_fixed_app_name scala-build
set_app_main_class com.mycompany.app.SparkPi

os::test::junit::declare_suite_start "$MY_SCRIPT"

echo "++ check_image"
check_image $S2I_TEST_IMAGE_SCALA

echo "++ test_manifest_file"
test_manifest_file true

echo "++ test_k8s_complete"
test_k8s_complete

echo "++ test_k8s_config"
test_k8s_config 3

os::test::junit::declare_suite_end
