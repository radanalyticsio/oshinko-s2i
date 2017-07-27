#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

set_worker_count $S2I_TEST_WORKERS

function ephemeral_app_completed() {
    set_defaults
    clear_spark_sleep
    run_app $1

    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    os::cmd::try_until_text 'oc logs dc/"$APP_NAME"' 'Deleting cluster' $((5*minute))
    os::cmd::try_until_failure 'oc get dc "$MASTER_DC"'
    os::cmd::try_until_failure 'oc get dc "$WORKER_DC"'

    # Delete the driver dc
    os::cmd::expect_success 'oc delete dc/"$APP_NAME"'
    os::cmd::try_until_failure 'oc get dc/"$APP_NAME"'
}

os::test::junit::declare_suite_start "$MY_SCRIPT"

# Make the S2I test image if it's not already in the project
make_image

echo ++ ephemeral_app_completed true
ephemeral_app_completed true

echo ++ ephemeral_app_completed false
ephemeral_app_completed false

os::test::junit::declare_suite_end
