#!/bin/bash
SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

function del_job_pod() {
    set_defaults
    set_test_mode
    run_job "bob"

    DRIVER=$(oc get pod -l app=bob-job --template='{{index .items 0 "metadata" "name"}}')
    os::cmd::try_until_text 'oc log "$DRIVER"' 'Cound not create an ephemeral cluster, created a shared cluster instead' $((5*minute))
    os::cmd::try_until_text 'oc log "$DRIVER"' "$1" $((5*minute))
    os::cmd::expect_success 'oc delete pod "$DRIVER"'
    os::cmd::try_until_text 'oc log "$DRIVER"' 'cluster not deleted'

    cleanup_job
    cleanup_cluster
}

# Define a bunch of functions and set a bunch of variables
source $SCRIPT_DIR/../common
set_worker_count $S2I_TEST_WORKERS

os::test::junit::declare_suite_start "$MY_SCRIPT"

# Make the S2I test image if it's not already in the project
make_image

del_job_pod "SparkContext: Running Spark"

os::test::junit::declare_suite_end
