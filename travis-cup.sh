#!/bin/bash

# Sometimes oc cluster up fails with a permission error and works when the test is relaunched.
# See if a retry within the same test works
set +e
built=false
for tries in {1..3}; do
    sudo oc cluster up # --host-config-dir=/home/travis/gopath/src/github.com/radanalyticsio/origin
    if [ "$?" -eq 0 ]; then
        built=true
        oc login -u system:admin
        break
    fi
    echo "Retrying oc cluster up after failure"
    sudo oc cluster down
done
set -e
if [ "$built" == false ]; then
    exit 1
fi
