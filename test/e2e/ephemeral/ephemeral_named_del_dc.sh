#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
source $TEST_DIR/common
source $SCRIPT_DIR/del_dc

set_worker_count $S2I_TEST_WORKERS

os::test::junit::declare_suite_start "$MY_SCRIPT"

# Make the S2I test image if it's not already in the project
make_image

# Run the dc tests with an ephemeral named cluster
echo del_dc \"Didn\'t find cluster\" \"bob\"
del_dc "Didn't find cluster" "bob"

echo 'del_dc "Waiting for spark master" "bob"'
del_dc "Waiting for spark master" "bob"

echo 'del_dc "Waiting for spark workers" "bob"'
del_dc "Waiting for spark workers" "bob"

echo 'del_dc "Running Spark" "bob"'
del_dc "Running Spark" "bob"

echo 'del_dc "SparkContext: Starting job" "bob"'
del_dc "SparkContext: Starting job" "bob"

os::test::junit::declare_suite_end
