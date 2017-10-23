#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

JAVATEMP_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i')/templates

SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
source $SCRIPT_DIR/../../builddc
source $SCRIPT_DIR/../../buildonly

RESOURCE_DIR=$TEST_DIR/resources
cp $JAVATEMP_DIR/javabuild.json $RESOURCE_DIR/javabuild.json
fix_template $RESOURCE_DIR/javabuild.json radanalyticsio/radanalytics-java-spark $S2I_TEST_IMAGE_JAVA
set_template $RESOURCE_DIR/javabuild.json
set_git_uri https://github.com/radanalyticsio/s2i-integration-test-apps
set_fixed_app_name java-build

set_worker_count $S2I_TEST_WORKERS

os::test::junit::declare_suite_start "$MY_SCRIPT"

echo "++ check_image"
check_image $S2I_TEST_IMAGE_JAVA

echo "++ build_test_no_app_name"
build_test_no_app_name

echo "++ test_no_source_or_image"
test_no_source_or_image

echo "++ build_test_app_file java-spark-pi-1.0-SNAPSHOT.jar"
build_test_app_file java-spark-pi-1.0-SNAPSHOT.jar

echo "++ test_git_ref"
test_git_ref $GIT_URI 6fa7763517d44a9f39d6b4f0a6c15737afbf2a5a

os::test::junit::declare_suite_end
