#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
source $SCRIPT_DIR/../../builddc

RESOURCE_DIR=$TEST_DIR/resources
set_template $RESOURCE_DIR/oshinko-python-spark-build-dc.json
set_git_uri https://github.com/radanalyticsio/s2i-integration-test-apps
set_worker_count $S2I_TEST_WORKERS
set_fixed_app_name pyspark-build

# Need a little preamble here to read the resources.yaml, create the pyspark template, and save
# it to the resources directory
set +e
if [ -f "$RESOURCE_DIR"/resources.yaml ]; then
    echo Using local resources.yaml
    oc create -f $RESOURCE_DIR/resources.yaml &> /dev/null
else
    echo Using https://radanalytics.io/resources.yaml
    oc create -f https://radanalytics.io/resources.yaml &> /dev/null
fi
oc export template oshinko-python-spark-build-dc -o json > $RESOURCE_DIR/oshinko-python-spark-build-dc.json
fix_template $RESOURCE_DIR/oshinko-python-spark-build-dc.json radanalyticsio/radanalytics-pyspark:stable $S2I_TEST_IMAGE_PYSPARK
set -e

os::test::junit::declare_suite_start "$MY_SCRIPT"

echo "++ check_image"
check_image $S2I_TEST_IMAGE_PYSPARK

echo "++ test_no_app_name"
test_no_app_name

echo "++ test_exit"
test_fixed_exit

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

echo "++ test_no_source_or_image"
test_no_source_or_image

echo "++ test_app_file app.py"
test_app_file app.py

echo "++ test_git_ref"
test_git_ref $GIT_URI 6fa7763517d44a9f39d6b4f0a6c15737afbf2a5a

os::test::junit::declare_suite_end
