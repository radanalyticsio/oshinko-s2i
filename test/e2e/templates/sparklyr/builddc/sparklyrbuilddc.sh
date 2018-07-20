#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
source $SCRIPT_DIR/../../builddc

SPARKLYR_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i')/templates
RESOURCE_DIR=$TEST_DIR/resources

cp  $SPARKLYR_DIR/sparklyrbuilddc.json $RESOURCE_DIR/sparklyrbuilddc.json
fix_template $RESOURCE_DIR/sparklyrbuilddc.json rimolive/radanalytics-sparklyr $S2I_TEST_IMAGE_SPARKLYR
set_template $RESOURCE_DIR/sparklyrbuilddc.json
set_git_uri https://github.com/tmckayus/r-openshift-ex.git
set_worker_count $S2I_TEST_WORKERS
set_fixed_app_name sparklyr-build

os::test::junit::declare_suite_start "$MY_SCRIPT"

echo "++ check_image"
check_image $S2I_TEST_IMAGE_SPARKLYR

echo "++ test_no_app_name"
test_no_app_name

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

echo "++ test_driver_host"
test_driver_host

echo "++ test_no_source_or_image"
test_no_source_or_image

#echo "++ test_app_file app.py"
#test_app_file app.py

echo "++ test_git_ref"
test_git_ref $GIT_URI 4acf0e83a8817ff4bc9922584d9cec689748305f

os::test::junit::declare_suite_end
