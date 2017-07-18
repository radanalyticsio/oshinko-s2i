#!/bin/bash
SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

# Define a bunch of functions and set a bunch of variables
source $SCRIPT_DIR/../common
set_worker_count $S2I_TEST_WORKERS

function non_ephemeral_app_completed() {
    set_defaults
    set_long_running
    clear_spark_sleep
    # If there is an arg the second is a cluster name
    if [ "$#" -eq 0 ]; then
        run_app
    else
        run_app $1
    fi

    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    os::cmd::try_until_text 'oc logs dc/bob' 'cluster is not ephemeral' $((5*minute))
    os::cmd::try_until_text 'oc logs dc/bob' 'cluster not deleted'

    # Cluster dcs should still be there
    os::cmd::try_until_success 'oc get dc "$MASTER_DC"'
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    cleanup_app
    cleanup_cluster
}

os::test::junit::declare_suite_start "$MY_SCRIPT"

# Make the S2I test image if it's not already in the project
make_image

echo 'non_ephemeral_app_completed "bob"'
non_ephemeral_app_completed "bob"

echo 'non_ephemeral_app_completed'
non_ephemeral_app_completed

os::test::junit::declare_suite_end
