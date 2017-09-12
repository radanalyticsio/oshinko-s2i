#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

function wait_for_incomplete_fix {
    set_defaults
    set_long_running
    run_app $1

    os::cmd::try_until_text 'oc logs dc/"$APP_NAME"' 'Waiting for spark master'
    cleanup_app

    # intentionally break the cluster by deleting one of the services
    # we'll put it back for the "fix"
    file=$(mktemp)
    os::cmd::expect_success 'oc export service "$GEN_CLUSTER_NAME"-ui > "$file"'
    os::cmd::expect_success 'oc delete service "$GEN_CLUSTER_NAME"-ui'

    run_app $1
    os::cmd::try_until_text 'oc logs dc/"$APP_NAME"' 'Found incomplete cluster' $((5*minute))
    os::cmd::expect_success 'oc create -f "$file"'
    rm $file

    os::cmd::try_until_text 'oc logs dc/"$APP_NAME"' "Found cluster"
    cleanup_app
    cleanup_cluster
}

set_worker_count $S2I_TEST_WORKERS

os::test::junit::declare_suite_start "$MY_SCRIPT"

# Make the S2I test image if it's not already in the project
make_image

wait_for_incomplete_fix true

os::test::junit::declare_suite_end
