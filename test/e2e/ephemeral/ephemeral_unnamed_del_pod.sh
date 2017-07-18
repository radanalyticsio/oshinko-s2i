#!/bin/bash
SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

# Define a bunch of functions and set a bunch of variables
source $SCRIPT_DIR/../common
source $SCRIPT_DIR/del_pod
set_worker_count $S2I_TEST_WORKERS

os::test::junit::declare_suite_start "$MY_SCRIPT"

# Make the S2I test image if it's not already in the project
make_image

del_pod_tests

os::test::junit::declare_suite_end
