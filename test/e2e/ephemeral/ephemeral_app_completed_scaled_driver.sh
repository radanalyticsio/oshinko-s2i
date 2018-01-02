#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

set_worker_count $S2I_TEST_WORKERS

function ephemeral_app_completed_scaled_driver() {
    set_defaults
    clear_spark_sleep
    run_app true

    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    DRIVER=$(oc get pod -l deploymentconfig=$APP_NAME --template='{{index .items 0 "metadata" "name"}}')
    os::cmd::try_until_text 'oc logs "$DRIVER"' 'Running Spark' $((5*minute))
    os::cmd::expect_success 'oc scale dc/"$APP_NAME" --replicas=2'

    os::cmd::try_until_text 'oc logs "$DRIVER"' 'Deleting cluster' $((5*minute))
    os::cmd::try_until_text 'oc logs "$DRIVER"' 'driver replica count > 0'
    os::cmd::try_until_text 'oc logs "$DRIVER"' 'cluster not deleted'

    cleanup_app $DRIVER
}

os::test::junit::declare_suite_start "$MY_SCRIPT"

# Make the S2I test image if it's not already in the project
make_image

ephemeral_app_completed_scaled_driver

os::test::junit::declare_suite_end
