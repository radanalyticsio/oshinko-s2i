#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

SCALATEMP_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/')/scala

SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
source $SCRIPT_DIR/../builddc
source $SCRIPT_DIR/../buildonly

set_git_uri https://github.com/pdmack/scala-sbt-s2i-test
set_template $SCALATEMP_DIR/scalabuild.json
set_fixed_app_name scala-build

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
test_git_ref $GIT_URI c7e91ecf8aa4fc6c36e04744a8fdae513839baa3

os::test::junit::declare_suite_end
