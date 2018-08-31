#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
source $SCRIPT_DIR/../../builddc

JAVATEMP_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i')/templates
RESOURCE_DIR=$TEST_DIR/resources

cp  $JAVATEMP_DIR/javabuilddc.json $RESOURCE_DIR/javabuilddc.json
fix_template $RESOURCE_DIR/javabuilddc.json radanalyticsio/radanalytics-java-spark $S2I_TEST_IMAGE_JAVA
set_template $RESOURCE_DIR/javabuilddc.json
set_git_uri https://github.com/radanalyticsio/s2i-integration-test-apps
set_worker_count 1
set_fixed_app_name java-k8s-test
set_app_main_class com.mycompany.app.JavaSparkPi

os::test::junit::declare_suite_start "$MY_SCRIPT"

echo "++ check_image"
check_image $S2I_TEST_IMAGE_JAVA

echo "++ test_manifest_file"
test_manifest_file true

echo "++ test_k8s_complete"
test_k8s_complete

echo "++ test_k8s_config"
test_k8s_config 3

os::test::junit::declare_suite_end
