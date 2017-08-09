#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
source $SCRIPT_DIR/../../builddc

PYSPARK_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/')/pyspark
set_template $PYSPARK_DIR/pysparkdc.json
set_worker_count $S2I_TEST_WORKERS

# Clear these flags
set_fixed_app_name

os::test::junit::declare_suite_start "$MY_SCRIPT"

# Make the S2I test image if it's not already in the project
make_image
set_image $TEST_IMAGE

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

os::test::junit::declare_suite_end
