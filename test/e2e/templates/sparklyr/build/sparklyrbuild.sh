#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

SPARKLYR_TEMP_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i')/templates

SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
source $SCRIPT_DIR/../../builddc
source $SCRIPT_DIR/../../buildonly

RESOURCE_DIR=$TEST_DIR/resources
cp $SPARKLYR_TEMP_DIR/sparklyrbuild.json $RESOURCE_DIR/sparklyrbuild.json
fix_template $RESOURCE_DIR/sparklyrbuild.json radanalyticsio/radanalytics-r-spark $S2I_TEST_IMAGE_SPARKLYR
set_template $RESOURCE_DIR/sparklyrbuild.json
set_git_uri https://github.com/tmckayus/r-openshift-ex.git
set_fixed_app_name sparklyr-build

set_worker_count $S2I_TEST_WORKERS

os::test::junit::declare_suite_start "$MY_SCRIPT"

echo "++ check_image"
check_image $S2I_TEST_IMAGE_SPARKLYR

# Do this first after check_image becaue it involves deleting all the existing buildconfigs
echo "++ build_test_no_app_name"
build_test_no_app_name

echo "++ test_no_source_or_image"
test_no_source_or_image

echo "++ test_context_dir"
test_context_dir

echo "++ build_test_app_file app.R"
build_test_app_file app.R

echo "++ test_git_ref"
test_git_ref $GIT_URI 4acf0e83a8817ff4bc9922584d9cec689748305f

os::test::junit::declare_suite_end
