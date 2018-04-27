#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
source $SCRIPT_DIR/../../builddc

TEMPLATE_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i')/templates
set_template $TEMPLATE_DIR/javadc.json
set_worker_count $S2I_TEST_WORKERS

# Clear these flags
set_fixed_app_name

os::test::junit::declare_suite_start "$MY_SCRIPT"

function poll_build() {
    # override poll_build from builddc because
    # in this case we never do a build beyond the
    # binary build we do directly, so polls will break!
    return
}

function test_no_app_name {
    set_defaults
    os::cmd::expect_success 'oc delete dc --all'
    os::cmd::try_until_text 'oc get pod -l deploymentconfig' 'No resources found'
    run_app_without_application_name
    os::cmd::try_until_not_text 'oc get pod -l deploymentconfig' 'No resources found' $((10*minute))
    DRIVER=$(oc get pod -l deploymentconfig --template='{{index .items 0 "metadata" "name"}}')
    os::cmd::try_until_text 'oc logs "$DRIVER"' 'cluster'
    os::cmd::expect_success 'oc delete dc --all'
}

set_git_uri https://github.com/radanalyticsio/s2i-integration-test-apps
set_app_main_class org.apache.spark.examples.JavaSparkPi

# Make the S2I test image if it's not already in the project
make_image $S2I_TEST_IMAGE_JAVA $GIT_URI
set_image $TEST_IMAGE

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

os::test::junit::declare_suite_end
