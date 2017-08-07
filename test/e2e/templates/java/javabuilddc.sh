#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
source $SCRIPT_DIR/../builddc

JAVATEMP_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/')/java
set_template $JAVATEMP_DIR/javabuilddc.json
set_git_uri https://github.com/radanalyticsio/jgrafzahl
set_worker_count $S2I_TEST_WORKERS
set_fixed_app_name java-build
set_app_main_class io.radanalytics.jgrafzahl.App

# Clear these
set_app_file
set_exit_flag

os::test::junit::declare_suite_start "$MY_SCRIPT"

echo "++ test_exit"
test_exit

echo "++ test_cluster_name"
test_cluster_name

echo "++ test_del_cluster"
test_del_cluster

echo "++ test_app_args"
test_app_args

echo "++ test_pod_info"
test_podinfo

echo "++ test_named_config"
test_named_config

echo "++ test_driver_config"
test_driver_config

echo "++ test_spark_options"
test_spark_options

echo "++ test_no_app_name"
test_no_app_name

echo "++ test_no_source_or_image"
test_no_source_or_image

echo "++ test_app_file"
test_app_file

echo "++ test_git_ref"
test_git_ref $GIT_URI ccb7b2064861e17985de8d269264deee8440f5a7

os::test::junit::declare_suite_end
