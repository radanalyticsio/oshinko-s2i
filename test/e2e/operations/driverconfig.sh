#!/bin/bash

TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

function test_spark_driver_config() {
    set_defaults
    set_driver_config
    run_app true
    os::cmd::try_until_text 'oc log dc/"$APP_NAME"' 'Spark configuration updated'
    cleanup_app

    delete_driver_config
    run_app true
    os::cmd::try_until_text 'oc log dc/"$APP_NAME"' 'Unable to read spark driver config'
    cleanup_app
}

set_worker_count $S2I_TEST_WORKERS

os::test::junit::declare_suite_start "$MY_SCRIPT"

# Make the S2I test image if it's not already in the project
make_image

test_spark_driver_config

os::test::junit::declare_suite_end
