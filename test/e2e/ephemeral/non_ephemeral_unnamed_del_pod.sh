#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
source $TEST_DIR/common
source $SCRIPT_DIR/del_pod_non_ephemeral

set_worker_count $S2I_TEST_WORKERS

os::test::junit::declare_suite_start "$MY_SCRIPT"

# Make the S2I test image if it's not already in the project
make_image

# Run a dc test against a non-ephemeral cluster
del_pod_non_ephemeral false

os::test::junit::declare_suite_end
