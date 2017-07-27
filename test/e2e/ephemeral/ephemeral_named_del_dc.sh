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
echo ++ del_dc \"Didn\'t find cluster\" true
del_dc "Didn't find cluster" true

echo ++ del_dc '"Waiting for spark master"' true
del_dc "Waiting for spark master" true

echo ++ del_dc '"Waiting for spark workers"' true
del_dc "Waiting for spark workers" true

echo ++ del_dc '"Running Spark"' true
del_dc "Running Spark" true

echo ++ del_dc '"SparkContext: Starting job"' true
del_dc "SparkContext: Starting job" true

os::test::junit::declare_suite_end
