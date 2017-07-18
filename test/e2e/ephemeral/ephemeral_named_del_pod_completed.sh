#!/bin/bash
SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

# Define a bunch of functions and set a bunch of variables
source $SCRIPT_DIR/../common
source $SCRIPT_DIR/del_pod_completed
set_worker_count $S2I_TEST_WORKERS

os::test::junit::declare_suite_start "$MY_SCRIPT"

# Make the S2I test image if it's not already in the project
make_image

pod_completed_tests "bob"

os::test::junit::declare_suite_end
