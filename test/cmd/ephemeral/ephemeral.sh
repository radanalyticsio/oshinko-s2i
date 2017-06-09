#!/bin/bash
# Save project and user, generate a temporary project name

# todo, this might need to be an argument
S2I_TEST_IMAGE=${S2I_TEST_IMAGE:-radanalytics-pyspark}
echo Using local image $S2I_TEST_IMAGE

ORIG_PROJECT=$(oc project -q)
PROJECT=test-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1)
SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
SPARK_IMAGE=docker.io/tmckay/openshift-spark:testpr3

function set_app_exit {
    DO_EXIT="true"
}

function clear_app_exit() {
    DO_EXIT="false"
}

function set_long_running {
    DEL_CLUSTER="false"
}

function set_ephemeral() {
    DEL_CLUSTER="true"
}

function set_spark_sleep() {
    SLEEP=300
}

function clear_spark_sleep() {
    SLEEP=0
}

function set_test_mode() {
    # we want the signal handler to delay so that we can read the pod logs after the pod is deleted   
    DO_TEST="true"
}

function clear_test_mode() {
    DO_TEST="false"
}

function init_config_map() {
    set +e
    oc delete configmap clusterconfig masterconfig workerconfig
    set -e
    oc create configmap masterconfig --from-file=$SCRIPT_DIR/masterconfig
    oc create configmap workerconfig --from-file=$SCRIPT_DIR/workerconfig
    oc create configmap clusterconfig --from-literal=workercount=$WORKER_COUNT \
                                      --from-literal=sparkimage=$SPARK_IMAGE \
                                      --from-literal=sparkmasterconfig=masterconfig \
                                      --from-literal=sparkworkerconfig=workerconfig
}

function set_worker_count() {
    if [ "${WORKER_COUNT:-0}" -ne "$1" ]; then
        WORKER_COUNT=$1
        init_config_map
    fi
}

function set_defaults() {
    set_ephemeral
    set_spark_sleep
    clear_app_exit
    clear_test_mode
}

function run_app() {
    # Launch the app using the service account and create a cluster
    if [ "$#" -eq 0 ]; then    
        os::cmd::expect_success 'oc new-app --file="$SCRIPT_DIR"/pysparkdc.json -p IMAGE=play -p APPLICATION_NAME=bob -p APP_EXIT="$DO_EXIT" -p APP_ARGS="$SLEEP" -p OSHINKO_DEL_CLUSTER="$DEL_CLUSTER" -p TEST_MODE="$DO_TEST" -p OSHINKO_NAMED_CONFIG=clusterconfig'
        os::cmd::try_until_not_text 'oc get rc bob-1 --template="{{index .metadata.labels \"uses-oshinko-cluster\"}}"' "<no value>" $((5*minute))
        GEN_CLUSTER_NAME=$(oc get rc bob-1 --template='{{index .metadata.labels "uses-oshinko-cluster"}}')
    else
        GEN_CLUSTER_NAME=$1
        os::cmd::expect_success 'oc new-app --file="$SCRIPT_DIR"/pysparkdc.json -p IMAGE=play -p OSHINKO_CLUSTER_NAME="$GEN_CLUSTER_NAME" -p APPLICATION_NAME=bob -p APP_EXIT="$DO_EXIT" -p APP_ARGS="$SLEEP" -p OSHINKO_DEL_CLUSTER="$DEL_CLUSTER" -p TEST_MODE="$DO_TEST" -p OSHINKO_NAMED_CONFIG=clusterconfig'
    fi 
    echo Using cluster name $GEN_CLUSTER_NAME
    MASTER_DC=$GEN_CLUSTER_NAME-m
    WORKER_DC=$GEN_CLUSTER_NAME-w
}

function run_job() {
    # Launch the app using the service account and create a cluster
    IMAGE_NAME=$(oc get is play --template="{{index .status \"dockerImageRepository\"}}")
    GEN_CLUSTER_NAME=$1
    os::cmd::expect_success 'oc new-app --file="$SCRIPT_DIR"/pysparkjob.json -p IMAGE="$IMAGE_NAME" -p OSHINKO_CLUSTER_NAME="$GEN_CLUSTER_NAME" -p APPLICATION_NAME=bob-job -p APP_EXIT="$DO_EXIT" -p APP_ARGS="$SLEEP" -p OSHINKO_DEL_CLUSTER="$DEL_CLUSTER" -p TEST_MODE="$DO_TEST"'
    echo Using cluster name $GEN_CLUSTER_NAME
    MASTER_DC=$GEN_CLUSTER_NAME-m
    WORKER_DC=$GEN_CLUSTER_NAME-w
}

function cleanup_app() {

    echo cleanup_app called
    os::cmd::expect_success 'oc scale dc/bob --replicas=0'
    os::cmd::try_until_text 'oc get pods -l deploymentconfig=bob' 'No resources found'
    os::cmd::expect_success 'oc delete dc/bob'
    if [ "$#" -eq 1 ]; then
        os::cmd::try_until_failure 'oc get dc "$MASTER_DC"'
        os::cmd::try_until_failure 'oc get dc "$WORKER_DC"'
        os::cmd::try_until_failure 'oc get service "$GEN_CLUSTER_NAME"'
        os::cmd::try_until_failure 'oc get service "$GEN_CLUSTER_NAME"-ui'
    fi
}

function cleanup_cluster() {
    echo cleanup_cluster called with cluster $GEN_CLUSTER_NAME

    # We get tricky here and just use try_until_failure for components that
    # might not actually exist, depending on what we've been doing
    # If present, they'll be deleted and the next call will fail
    os::cmd::try_until_failure 'oc delete service "$GEN_CLUSTER_NAME"-ui'
    os::cmd::try_until_failure 'oc delete service "$GEN_CLUSTER_NAME"'
    os::cmd::try_until_failure 'oc delete dc "$MASTER_DC"'
    os::cmd::try_until_failure 'oc delete dc "$WORKER_DC"'
    if [ "$#" -eq 0 ]; then
        os::cmd::try_until_failure 'oc get service "$GEN_CLUSTER_NAME"'
        os::cmd::try_until_failure 'oc get service "$GEN_CLUSTER_NAME"-ui'
        os::cmd::try_until_failure 'oc get dc "$MASTER_DC"'
        os::cmd::try_until_failure 'oc get dc "$WORKER_DC"'
    fi

} 

function cleanup_job() {
    echo cleanup_job called
    os::cmd::expect_success 'oc delete job bob-job'
    os::cmd::try_until_text 'oc get pods -l app=bob-job' 'No resources found'
}

function del_dc() {
    echo running del_dc
    set_defaults
    # If there are 2 args the second is a cluster name
    if [ "$#" -eq 1 ]; then
        run_app
    else
        run_app $2
    fi

    # Wait until a particular message is seen and the cluster dcs exist
    os::cmd::try_until_text 'oc logs dc/bob' "$1" $((5*minute))
    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    # Delete the driver dc
    os::cmd::expect_success 'oc delete dc/bob'
    os::cmd::try_until_failure 'oc get dc/bob'

    # Check for the master and worker dcs, they should be gone and won't reappear
    os::cmd::try_until_failure 'oc get dc "$MASTER_DC"'
    os::cmd::try_until_failure 'oc get dc "$WORKER_DC"'
}

function del_dc_non_ephemeral() {
    echo running del_dc_non_ephemeral 
    set_defaults
    set_test_mode 
    set_long_running
    # If there are 2 args the second is a cluster name
    if [ "$#" -eq 1 ]; then
        run_app
    else
        run_app $2
    fi

    # Wait until a particular message is seen and the cluster pods exist
    os::cmd::try_until_text 'oc logs dc/bob' "$1" $((5*minute))
    DRIVER=$(oc get pod -l deploymentconfig=bob --template='{{index .items 0 "metadata" "name"}}')

    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    os::cmd::expect_success 'oc delete dc bob'
    os::cmd::try_until_text 'oc logs "$DRIVER"' 'cluster is not ephemeral'

    os::cmd::try_until_success 'oc get dc "$MASTER_DC"'
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    cleanup_cluster
}

function app_completed_ephemeral() {
    echo running app_completed_ephemeral
    set_defaults
    clear_spark_sleep
    # If there's an arg it's a cluster name
    if [ "$#" -eq 0 ]; then
        run_app
    else
        run_app $1
    fi

    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    os::cmd::try_until_text 'oc logs dc/bob' 'Deleting cluster' $((5*minute))
    os::cmd::try_until_failure 'oc get dc "$MASTER_DC"'
    os::cmd::try_until_failure 'oc get dc "$WORKER_DC"'

    # Delete the driver dc
    os::cmd::expect_success 'oc delete dc/bob'
    os::cmd::try_until_failure 'oc get dc/bob'
}

function app_completed_cluster_remains() {
    echo  running app_completed_cluster_remains 
    set_defaults
    set_long_running
    clear_spark_sleep
    run_app "steve"
    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    os::cmd::try_until_text 'oc logs dc/bob' 'cluster is not ephemeral' $((5*minute))
    os::cmd::try_until_text 'oc logs dc/bob' 'cluster not deleted'

    # Cluster dcs should still be there
    os::cmd::try_until_success 'oc get dc "$MASTER_DC"'
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    cleanup_app
    cleanup_cluster
}

function del_job_pod() {
    echo running del_job_pod
    set_defaults
    set_test_mode
    run_job "bob"

    DRIVER=$(oc get pod -l app=bob-job --template='{{index .items 0 "metadata" "name"}}')
    os::cmd::try_until_text 'oc log "$DRIVER"' 'Cound not create an ephemeral cluster, created a shared cluster instead'
    os::cmd::try_until_text 'oc log "$DRIVER"' "$1"
    os::cmd::expect_success 'oc delete pod "$DRIVER"'
    os::cmd::try_until_text 'oc log "$DRIVER"' 'cluster not deleted'

    cleanup_job
    cleanup_cluster
}

function del_pod() {
    echo running del_pod with cluster $GEN_CLUSTER_NAME
    # Wait until a particular message is seen and the cluster pods exist
    os::cmd::try_until_text 'oc logs dc/bob' "$1" $((5*minute))
   
    # Have to guarantee that the pods are there and not just the dcs because we're going to get their names next ....
    os::cmd::try_until_success 'oc get pod -l deploymentconfig="$MASTER_DC" --template="{{index .items 0 \"metadata\" \"name\"}}"' $((2*minute))
    os::cmd::try_until_success 'oc get pod -l deploymentconfig="$WORKER_DC" --template="{{index .items 0 \"metadata\" \"name\"}}"'
	
    # Record the names of the pods for driver, master, and worker
    DRIVER=$(oc get pod -l deploymentconfig=bob --template='{{index .items 0 "metadata" "name"}}')
    WORKER=$(oc get pod -l deploymentconfig=$WORKER_DC --template='{{index .items 0 "metadata" "name"}}')
    MASTER=$(oc get pod -l deploymentconfig=$MASTER_DC --template='{{index .items 0 "metadata" "name"}}')

    # Delete the driver pod and check that the master and worker pods do not disappear.
    # As long as the repl count has been left at 1, deleting the driver pod should cause
    # a respin of the driver against the same cluster.
    # Check that the old pod went away and that dc logs show the driver waiting for the
    # spark master without creating a cluster.
    os::cmd::expect_success 'oc delete pod "$DRIVER"'
    os::cmd::try_until_failure 'oc get pod "$DRIVER"'

    # We should see a respin here with the "found cluster" message
    os::cmd::try_until_text 'oc logs dc/bob' "Found cluster" $((5*minute))

    # Same master and worker pods should still exist
    os::cmd::expect_success 'oc get pod "$MASTER"'
    os::cmd::expect_success 'oc get pod "$WORKER"'
}

function del_pod_completed() {
    echo running del_pod_completed with cluster $GEN_CLUSTER_NAME
    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    # Wait until a particular message is seen and the cluster pods exist
    os::cmd::try_until_text 'oc logs dc/bob' 'Deleting cluster' $((5*minute))

    # Because the app was allowed to complete, the cluster should be deleted
    os::cmd::try_until_failure 'oc get dc "$MASTER_DC"'
    os::cmd::try_until_failure 'oc get dc "$WORKER_DC"'

    # Delete the driver pod and check that a new driver is started which recreates the cluster
    DRIVER=$(oc get pod -l deploymentconfig=bob --template='{{index .items 0 "metadata" "name"}}')
    os::cmd::expect_success 'oc delete pod "$DRIVER"'
    os::cmd::try_until_failure 'oc get pod "$DRIVER"'

    # In a case with a generated cluster name we don't know the new name, so
    # just look for spark start
    os::cmd::try_until_text 'oc logs dc/bob' "Didn't find cluster"
    os::cmd::try_until_text 'oc logs dc/bob' "Running Spark" $((5*minute))
}

function pod_tests() {
    # In these cases we delete the pod at various points before the application completes.
    # If the app has not completed, the signal handler will leave the cluster.
    # We re-use the same app and the same cluster

    set_defaults
    # If there's an arg it's a cluster name
    if [ "$#" -eq 0 ]; then
        run_app
    else
        run_app $1
    fi

    del_pod "Didn't find cluster"
    del_pod "Waiting for spark master"
    del_pod "Running Spark"
    del_pod "SparkContext: Starting job"
    cleanup_app wait_for_cluster_del

    # If the app has completed, the cluster will be deleted and restarting the app should create a new one.
    # We have to run the app again here because we want to clear the sleep
    clear_spark_sleep
    if [ "$#" -eq 0 ]; then
        run_app
    else
        run_app $1
    fi
    del_pod_completed
    cleanup_app wait_for_cluster_del
}

function pod_test_non_ephemeral() {
    echo running pod_test_non_ephemeral
    set_defaults
    set_long_running
    set_test_mode
    run_app $1

    os::cmd::try_until_text 'oc logs dc/bob' "Running Spark" $((5*minute))

    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    # Record the name of the pod for the driver
    DRIVER=$(oc get pod -l deploymentconfig=bob --template='{{index .items 0 "metadata" "name"}}')

    os::cmd::expect_success 'oc delete pod "$DRIVER"'
    os::cmd::try_until_text 'oc logs "$DRIVER"' 'cluster is not ephemeral'
    os::cmd::try_until_failure 'oc get pod "$DRIVER"'

    # There should have been a new pod spun up by the dc, and it should have found the cluster
    os::cmd::try_until_text 'oc logs dc/bob' 'Found cluster'

    cleanup_app
    cleanup_cluster
}

function wait_for_incomplete_delete {
    echo running wait_for_incomplete_delete
    set_defaults
    set_long_running
    run_app $1

    os::cmd::try_until_text 'oc logs dc/bob' 'Waiting for spark master'
    cleanup_app

    # intentionally break the cluster by deleting one of the services
    os::cmd::expect_success 'oc delete service "$GEN_CLUSTER_NAME"-ui'

    # Now run the app again against the broken cluster
    run_app $1
    os::cmd::try_until_text 'oc logs dc/bob' 'Found incomplete cluster'

    # we can't wait here because as soon as the cluster is deleted,
    # the pod will start creating it again.
    cleanup_cluster dontwait

    os::cmd::try_until_text 'oc logs dc/bob' "Didn't find cluster"
    os::cmd::try_until_text 'oc logs dc/bob' "Waiting for spark master"
    cleanup_app
    cleanup_cluster
}

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

function scaled_app_completed_cluster_remains() {
    echo running scaled_app_completed_cluster_remains
    set_defaults
    clear_spark_sleep
    run_app "bob"

    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    DRIVER=$(oc get pod -l deploymentconfig=bob --template='{{index .items 0 "metadata" "name"}}')
    os::cmd::try_until_text 'oc logs "$DRIVER"' 'Running Spark' $((5*minute))
    os::cmd::expect_success 'oc scale dc/bob --replicas=2'
    	
    os::cmd::try_until_text 'oc logs "$DRIVER"' 'Deleting cluster' $((5*minute))
    os::cmd::try_until_text 'oc logs "$DRIVER"' 'driver replica count > 0'
    os::cmd::try_until_text 'oc logs "$DRIVER"' 'cluster not deleted'

    cleanup_app wait_for_cluster_del
}

function redeploy_cluster_removed() {
    echo running redeploy_cluster_removed
    set_defaults
    set_app_exit
    set_test_mode 
    run_app "bob"

    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    DRIVER=$(oc get pod -l deploymentconfig=bob --template='{{index .items 0 "metadata" "name"}}')
    os::cmd::try_until_failure 'oc get pod bob-1-deploy'
    os::cmd::expect_success 'oc deploy dc/bob --latest'

    os::cmd::try_until_text 'oc logs "$DRIVER"' "Deleting cluster" $((5*minute))
    os::cmd::try_until_failure 'oc get pod "$DRIVER"'

    DRIVER=$(oc get pod -l deployment=bob-2 --template='{{index .items 0 "metadata" "name"}}')
    os::cmd::try_until_text 'oc logs "$DRIVER"' "Didn't find cluster"
    os::cmd::try_until_text 'oc logs "$DRIVER"' "Waiting for spark master"

    cleanup_app wait_for_cluster_del
}

source "${SCRIPT_DIR}/../../../hack/lib/init.sh"
trap os::test::junit::reconcile_output EXIT

os::test::junit::declare_suite_start "cmd/cluster"
os::cmd::expect_success 'oc new-project "$PROJECT"'
os::cmd::expect_success 'oc create sa oshinko'
os::cmd::expect_success 'oc policy add-role-to-user admin system:serviceaccount:"$PROJECT":oshinko -n "$PROJECT"'

# The ip address of the internal registry may be passed as the first argument to
# support running against an openshift that is not "oc cluster up". In the case of
# "oc cluster up", the docker on the host is available from openshift so no special
# pushes of images have to be done. In the case of a "normal" openshift cluster, the
# image we'll use for build has to be available as an imagestream.
if [ "$#" -eq 0 ]; then
    os::cmd::expect_success 'oc new-build --name=play "$S2I_TEST_IMAGE" --binary'
else
    docker login -u tmckay -p $(oc whoami -t) $1
    docker tag $S2I_TEST_IMAGE $1/$PROJECT/radanalytics-pyspark
    docker push $1/$PROJECT/radanalytics-pyspark
    os::cmd::expect_success 'oc new-build --name=play --image-stream=radanalytics-pyspark --binary'
fi
os::cmd::expect_success 'oc start-build play --from-file="$SCRIPT_DIR"/play'

# Variable assignments need to happen outsid of os:cmd wrappers
BUILDNUM=$(oc get buildconfig play --template='{{index .status "lastVersion"}}')

# Wait for the build to finish
os::cmd::try_until_text 'oc get build play-"$BUILDNUM" --template="{{index .status \"phase\"}}"' "Complete" $((5*minute))

set_worker_count 3

# Run the dc tests with an ephemeral cluster and a name supplied from env
echo Running dc tests with an ephemeral named cluster
del_dc "Didn't find cluster" "bob"
del_dc "Waiting for spark master" "bob"
del_dc "Waiting for spark workers" "bob"
del_dc "Running Spark" "bob"
del_dc "SparkContext: Starting job" "bob"

# Run a few of the dc tests with an ephemeral cluster and a generated cluster name
echo Running dc tests with an ephemeral un-named cluster
del_dc "Waiting for spark workers" 
del_dc "SparkContext: Starting job"

# Run a dc test against a non-ephemeral cluster
echo Running dc test with a non-ephemeral cluster
del_dc_non_ephemeral "Running Spark" "steve"

# Run some app completion tests
echo Running app completion test with ephemeral cluster
app_completed_ephemeral

echo Running app completion test with non-ephemeral cluster
app_completed_cluster_remains

# We may not have a clear use case for a scaled driver, but we can't stop it 
echo Running app completion test with scaled driver and ephemeral cluster
scaled_app_completed_cluster_remains

echo "Running pod tests with an ephemeral named cluster"
pod_tests "bob"

echo "Running pod tests with an ephemeral un-named cluster"
pod_tests

echo Running pod test with a non-ephemeral cluster
# In this test we intentionally leave the non-ephemeral cluster running
# so that we can test the "incomplete" cluster functionality aftwerward
pod_test_non_ephemeral steve

echo Running wait for incomplete tests
wait_for_incomplete_delete incdel
wait_for_incomplete_fix incfix

echo Running redeploy test with ephemeral cluster
redeploy_cluster_removed

echo "Running job test"
del_job_pod "Running Spark"

os::cmd::expect_success 'oc delete project "$PROJECT"'
os::test::junit::declare_suite_end
oc project $ORIG_PROJECT
