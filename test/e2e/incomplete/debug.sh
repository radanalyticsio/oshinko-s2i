#!/bin/bash

function wait_for_incomplete_fix {
    echo running wait_for_incomplete_fix
    set_defaults
    set_long_running
    run_app $1

    os::cmd::try_until_text 'oc logs dc/bob' 'Waiting for spark master'
    cleanup_app

    # intentionally break the cluster by deleting one of the services
    # we'll put it back for the "fix"
    file=$(mktemp)
    os::cmd::expect_success 'oc export service "$GEN_CLUSTER_NAME"-ui > "$file"'
    os::cmd::expect_success 'oc delete service "$GEN_CLUSTER_NAME"-ui'

    run_app $1
    os::cmd::try_until_text 'oc logs dc/bob' 'Found incomplete cluster'
    os::cmd::expect_success 'oc create -f "$file"'
    rm $file

    os::cmd::try_until_text 'oc logs dc/bob' "Found cluster"
    cleanup_app
    cleanup_cluster
}

function my_make_image {
    set +e
    oc get buildconfig play > /dev/null
    res=$?
    set -e
    if [ "$res" -ne 0 ]; then
        # The ip address of the internal registry may be set to support running against
        # an openshift that is not "oc cluster up". In the case of "oc cluster up", the docker
        # on the host is available from openshift so no special pushes of images have to be done.
        # In the case of a "normal" openshift cluster, the image we'll use for build has to be
        # available as an imagestream.
        if [ -z "${S2I_TEST_INTEGRATED_REGISTRY}" ]; then
	    echo test image is $S2I_TEST_IMAGE
	    docker images
            os::cmd::expect_success 'oc new-build --name=play "$S2I_TEST_IMAGE" --binary'
        else
            docker login -u $(oc whoami) -p $(oc whoami -t) ${S2I_TEST_INTEGRATED_REGISTRY}
            docker tag ${S2I_TEST_IMAGE} ${S2I_TEST_INTEGRATED_REGISTRY}/${PROJECT}/radanalytics-pyspark
            docker push ${S2I_TEST_INTEGRATED_REGISTRY}/${PROJECT}/radanalytics-pyspark
            os::cmd::expect_success 'oc new-build --name=play --image-stream=radanalytics-pyspark --binary'
        fi
    fi
    BUILDNUM=$(oc get buildconfig play --template='{{index .status "lastVersion"}}')
    set +e
    oc get build play-$BUILDNUM > /dev/null
    res=$?
    set -e
    if [ "$res" -ne 0 ]; then
        echo "Buildconfig but no build found, starting..."
        oc start-build play --from-file="$COMMON_DIR"/play
        BUILDNUM=$(oc get buildconfig play --template='{{index .status "lastVersion"}}')
	oc logs -f buildconfig/play
    else
        # Make sure that the build is complete. If not, start another one.
	phase=$(oc get build play-"$BUILDNUM" --template="{{index .status \"phase\"}}")
        if [ "$phase" != "Running" -a "$phase" != "Complete" ]; then
            echo "Build phase is $phase, restarting..."
            os::cmd::expect_success 'oc start-build play --from-file="$COMMON_DIR"/play'
            BUILDNUM=$(oc get buildconfig play --template='{{index .status "lastVersion"}}')
        fi
    fi
    # Wait for the build to finish
    os::cmd::try_until_text 'oc get build play-"$BUILDNUM" --template="{{index .status \"phase\"}}"' "Complete" $((5*minute))
}


SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

# Define a bunch of functions and set a bunch of variables
source $SCRIPT_DIR/../common
set_worker_count $S2I_TEST_WORKERS

os::test::junit::declare_suite_start "$MY_SCRIPT"

# Make the S2I test image if it's not already in the project
my_make_image

wait_for_incomplete_fix "incfix"

os::test::junit::declare_suite_end
