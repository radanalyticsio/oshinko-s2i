#!/bin/bash
# Save project and user, generate a temporary project name
SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)


source "${SCRIPT_DIR}/../../hack/lib/init.sh"
trap os::test::junit::reconcile_output EXIT

os::test::junit::declare_suite_start "cmd/hack"

oc new-app hello-world
os::cmd::try_until_success 'oc get pod hello-world-1-deploy' $((1*minute)) 0.1

# Orchestrate a failed deployment
oc delete dc hello-world &
oc delete rc hello-world-1

os::cmd::try_until_failure 'oc get dc hello-world'

sleep 1
 
os::cmd::try_until_failure 'oc get rc hello-world-1'

os::cmd::expect_success 'oc new-app hello-world'

os::test::junit::declare_suite_end
