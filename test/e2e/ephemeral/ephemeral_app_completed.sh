#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

set_worker_count $S2I_TEST_WORKERS

function ephemeral_app_completed() {
    set_defaults
    clear_spark_sleep
    # If there's an arg it's a cluster name
    if [ "$#" -eq 0 ]; then
        run_app
    else
        run_app $1
    fi

    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    os::cmd::try_until_text 'oc logs dc/bob' 'Deleting cluster' $((5*minute))
    os::cmd::try_until_failure 'oc get dc "$MASTER_DC"'
    os::cmd::try_until_failure 'oc get dc "$WORKER_DC"'

    # Delete the driver dc
    os::cmd::expect_success 'oc delete dc/bob'
    os::cmd::try_until_failure 'oc get dc/bob'
}

os::test::junit::declare_suite_start "$MY_SCRIPT"

# Make the S2I test image if it's not already in the project
make_image

echo 'ephemeral_app_completed "bob"'
ephemeral_app_completed "bob"

echo 'ephemeral_app_completed'
ephemeral_app_completed

os::test::junit::declare_suite_end
