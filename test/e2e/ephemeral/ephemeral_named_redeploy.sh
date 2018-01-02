#!/bin/bash
SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

function redeploy_cluster_removed() {
    set_defaults
    clear_spark_sleep
    set_app_exit
    run_app true

    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    DRIVER=$(oc get pod -l deploymentconfig="$APP_NAME" --template='{{index .items 0 "metadata" "name"}}')
    os::cmd::try_until_failure 'oc get pod "$APP_NAME"-1-deploy'
    os::cmd::expect_success 'oc deploy dc/"$APP_NAME" --latest'

    os::cmd::try_until_failure 'oc get pod "$DRIVER"'
    os::cmd::try_until_failure 'oc get dc "$MASTER_DC"'
    os::cmd::try_until_failure 'oc get dc "$WORKER_DC"'

    DRIVER=$(oc get pod -l deployment="$APP_NAME"-2 --template='{{index .items 0 "metadata" "name"}}')
    os::cmd::try_until_failure 'oc get dc "$MASTER_DC"'
    os::cmd::try_until_failure 'oc get dc "$WORKER_DC"'

    cleanup_app
}

# Define a bunch of functions and set a bunch of variables
source $SCRIPT_DIR/../common
set_worker_count $S2I_TEST_WORKERS

os::test::junit::declare_suite_start "$MY_SCRIPT"

# Make the S2I test image if it's not already in the project
make_image

redeploy_cluster_removed

os::test::junit::declare_suite_end
