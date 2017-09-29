#!/bin/bash

FAIL_ON_PUSH=false

while true; do
    set +e
    test/e2e/run.sh $1
    makeres=$?
    set -e
    if [ "$makeres" -ne 0 ]; then
	set +e
        source test/e2e/failonpush
	set -e
        if [ "$FAIL_ON_PUSH" == true ]; then
            echo "failed on push, going to retry"
            sleep 5
	    sudo oc cluster down
	    ./travis-cup.sh
	    sudo chmod -R a+rwX /home/travis/.kube
        else
            exit $makeres
        fi
    else
        break
    fi
done
