#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

PYSPARK_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i')/templates

SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
source $SCRIPT_DIR/../../builddc
source $SCRIPT_DIR/../../buildonly

RESOURCE_DIR=$TEST_DIR/resources
cp $PYSPARK_DIR/pysparkbuild.json $RESOURCE_DIR/pysparkbuild.json
fix_template $RESOURCE_DIR/pysparkbuild.json radanalyticsio/radanalytics-pyspark $S2I_TEST_IMAGE_PYSPARK
set_template $RESOURCE_DIR/pysparkbuild.json
set_git_uri https://github.com/radanalyticsio/s2i-integration-test-apps
set_fixed_app_name pyspark-build

set_worker_count $S2I_TEST_WORKERS

os::test::junit::declare_suite_start "$MY_SCRIPT"

echo "++ check_image"
check_image $S2I_TEST_IMAGE_PYSPARK

echo "++ build_test_no_app_name"
build_test_no_app_name

echo "++ test_no_source_or_image"
test_no_source_or_image

echo "++ build_test_app_file app.py"
build_test_app_file app.py

echo "++ test_git_ref"
test_git_ref $GIT_URI 6fa7763517d44a9f39d6b4f0a6c15737afbf2a5a

os::test::junit::declare_suite_end
