#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

JAVATEMP_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/')/java

SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
source $SCRIPT_DIR/../builddc
source $SCRIPT_DIR/../buildonly

set_git_uri https://github.com/radanalyticsio/jgrafzahl
set_template $JAVATEMP_DIR/javabuild.json
set_fixed_app_name java-build

set_worker_count $S2I_TEST_WORKERS

os::test::junit::declare_suite_start "$MY_SCRIPT"

echo "++ build_test_no_app_name"
build_test_no_app_name

echo "++ test_no_source_or_image"
test_no_source_or_image

set_app_file myappfile
echo "++ build_test_app_file myappfile"
build_test_app_file

set_app_file
echo "++ build_test_app_file"
build_test_app_file

echo "++ test_git_ref"
test_git_ref $GIT_URI ccb7b2064861e17985de8d269264deee8440f5a7

os::test::junit::declare_suite_end
