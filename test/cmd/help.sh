#!/bin/bash
source "$(dirname "${BASH_SOURCE}")/../../hack/lib/init.sh"
trap os::test::junit::reconcile_output EXIT

os::test::junit::declare_suite_start "cmd/help"
# This test validates the help commands and output text

# verify some default commands
os::cmd::expect_success "_output/oshinko-cli help"
os::test::junit::declare_suite_end
