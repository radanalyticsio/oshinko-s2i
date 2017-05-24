#!/bin/bash
# Save project and user, generate a temporary project name
LOCAL_IMAGE=tmckay/radanalytics-pyspark
ORIG_PROJECT=$(oc project -q)
PROJECT=test-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1)
SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

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
    DO_TEST="true"
}

function clear_test_mode() {
    DO_TEST="false"
}

function run_app() {
    # Launch the app using the service account and create a cluster
    if [ "$#" -eq 0 ]; then    
        os::cmd::expect_success 'oc new-app --file="$SCRIPT_DIR"/pysparkdc.json -p IMAGE=play -p APPLICATION_NAME=bob -p APP_EXIT="$DO_EXIT" -p APP_ARGS="$SLEEP" -p OSHINKO_DEL_CLUSTER="$DEL_CLUSTER" -p TEST_MODE="$DO_TEST"'
        os::cmd::try_until_not_text 'oc get rc bob-1 --template="{{index .metadata.labels \"uses-oshinko-cluster\"}}"' "<no value>" $((5*minute))
        GEN_CLUSTER_NAME=$(oc get rc bob-1 --template='{{index .metadata.labels "uses-oshinko-cluster"}}')
        echo Generated cluster $GEN_CLUSTER_NAME
    else
        GEN_CLUSTER_NAME=$1
        os::cmd::expect_success 'oc new-app --file="$SCRIPT_DIR"/pysparkdc.json -p IMAGE=play -p OSHINKO_CLUSTER_NAME="$GEN_CLUSTER_NAME" -p APPLICATION_NAME=bob -p APP_EXIT="$DO_EXIT" -p APP_ARGS="$SLEEP" -p OSHINKO_DEL_CLUSTER="$DEL_CLUSTER" -p TEST_MODE="$DO_TEST"'
        echo Using cluster name $GEN_CLUSTER_NAME
    fi
    MASTER_DC=$GEN_CLUSTER_NAME-m
    WORKER_DC=$GEN_CLUSTER_NAME-w
}

function del_dc() {
    echo running del_dc
    set_spark_sleep
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
    set_spark_sleep
    set_test_mode # we want the signal handler to delay so that we can read the pod logs after the dc is deleted
    # If there are 2 args the second is a cluster name
    if [ "$#" -eq 1 ]; then
        run_app
    else
        run_app $2
    fi
    clear_test_mode

    # Wait until a particular message is seen and the cluster pods exist
    os::cmd::try_until_text 'oc logs dc/bob' "$1" $((5*minute))
    DRIVER=$(oc get pod -l deploymentconfig=bob --template='{{index .items 0 "metadata" "name"}}')

    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    os::cmd::expect_success 'oc delete dc bob'
    os::cmd::try_until_text 'oc logs "$DRIVER"' 'cluster is not ephemeral'

    os::cmd::try_until_success 'oc get dc "$MASTER_DC"'
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'
}

function del_dc_completed() {
    echo running del_dc_completed
    clear_spark_sleep
    # If there are 2 args the second is a cluster name
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

function del_pod_cluster_remains() {
    echo running del_pod_cluster_remains with cluster $GEN_CLUSTER_NAME
    # Wait until a particular message is seen and the cluster pods exist
    os::cmd::try_until_text 'oc logs dc/bob' "$1" $((5*minute))

    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    # Record the name of the pod for the driver
    DRIVER=$(oc get pod -l deploymentconfig=bob --template='{{index .items 0 "metadata" "name"}}')

    os::cmd::expect_success 'oc delete pod "$DRIVER"'
    os::cmd::try_until_text 'oc logs "$DRIVER"' 'cluster is not ephemeral'

    os::cmd::try_until_success 'oc get dc "$MASTER_DC"'
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'
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
    # just look for spark submit
    os::cmd::try_until_text 'oc logs dc/bob' "Didn't find cluster"
    os::cmd::try_until_text 'oc logs dc/bob' "spark-submit" $((5*minute))
}

function app_completed_cluster_remains() {
    echo  running app_completed_cluster_remains with cluster $GEN_CLUSTER_NAME
    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    os::cmd::try_until_text 'oc logs dc/bob' 'cluster is not ephemeral' $((5*minute))
    os::cmd::try_until_text 'oc logs dc/bob' 'cluster not deleted'

    # Cluster dcs should still be there
    os::cmd::try_until_success 'oc get dc "$MASTER_DC"'
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'
}

function scaled_app_completed_cluster_remains() {
    echo  running scaled_app_completed_cluster_remains with cluster $GEN_CLUSTER_NAME
    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    DRIVER=$(oc get pod -l deploymentconfig=bob --template='{{index .items 0 "metadata" "name"}}')
    os::cmd::try_until_text 'oc logs "$DRIVER"' 'spark-submit' $((5*minute))
    os::cmd::expect_success 'oc scale dc/bob --replicas=2'
    	
    os::cmd::try_until_text 'oc logs "$DRIVER"' 'Deleting cluster' $((5*minute))
    os::cmd::try_until_text 'oc logs "$DRIVER"' 'driver replica count > 0'
    os::cmd::try_until_text 'oc logs "$DRIVER"' 'cluster not deleted'
}


function redeploy_cluster_removed() {
    echo  running redeploy_cluster_removed with cluster $GEN_CLUSTER_NAME
    os::cmd::try_until_success 'oc get dc "$MASTER_DC"' $((2*minute))
    os::cmd::try_until_success 'oc get dc "$WORKER_DC"'

    DRIVER=$(oc get pod -l deploymentconfig=bob --template='{{index .items 0 "metadata" "name"}}')
    os::cmd::try_until_failure 'oc get pod bob-1-deploy'
    os::cmd::expect_success 'oc deploy dc/bob --latest'

    os::cmd::try_until_text 'oc logs "$DRIVER"' "Deleting cluster" $((5*minute))
    os::cmd::try_until_failure 'oc get pod "$DRIVER"'

    DRIVER=$(oc get pod -l deployment=bob-2 --template='{{index .items 0 "metadata" "name"}}')
    os::cmd::try_until_text 'oc logs "$DRIVER"' "Didn't find cluster"
}



function cleanup_app() {

    echo cleanup_app called
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
    os::cmd::expect_success 'oc delete dc "$MASTER_DC"'
    os::cmd::expect_success 'oc delete dc "$WORKER_DC"'
    os::cmd::try_until_failure 'oc get dc "$MASTER_DC"'
    os::cmd::try_until_failure 'oc get dc "$WORKER_DC"'
    os::cmd::expect_success 'oc delete service "$GEN_CLUSTER_NAME"'
    os::cmd::expect_success 'oc delete service "$GEN_CLUSTER_NAME"-ui'
    os::cmd::try_until_failure 'oc get service "$GEN_CLUSTER_NAME"'
    os::cmd::try_until_failure 'oc get service "$GEN_CLUSTER_NAME"-ui'
} 


source "${SCRIPT_DIR}/../../hack/lib/init.sh"
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
    os::cmd::expect_success 'oc new-build --name=play "$LOCAL_IMAGE" --binary'
else
    docker login -u tmckay -p $(oc whoami -t) $1
    docker tag $LOCAL_IMAGE $1/$PROJECT/radanalytics-pyspark
    docker push $1/$PROJECT/radanalytics-pyspark
    os::cmd::expect_success 'oc new-build --name=play --image-stream=radanalytics-pyspark --binary'
fi
os::cmd::expect_success 'oc start-build play --from-file="$SCRIPT_DIR"/play'

# Variable assignments need to happen outsid of os:cmd wrappers
BUILDNUM=$(oc get buildconfig play --template='{{index .status "lastVersion"}}')

# Wait for the build to finish
os::cmd::try_until_text 'oc get build play-"$BUILDNUM" --template="{{index .status \"phase\"}}"' "Complete" $((5*minute))

# Init our option variables
set_ephemeral
set_spark_sleep
clear_app_exit
clear_test_mode

# Run the dc tests with an ephemeral cluster and a name supplied from env
echo Running dc tests with a set name
del_dc "Didn't find cluster" "bob"
del_dc "Waiting for spark master" "bob"
del_dc "Waiting for spark workers" "bob"
del_dc "spark-submit" "bob"
del_dc "SparkContext: Starting job" "bob"
del_dc_completed "bob"

# Run a few of the dc tests with an ephemeral cluster and a generated cluster name
echo Running dc tests with a generated name
del_dc "Waiting for spark workers" 
del_dc "SparkContext: Starting job"
del_dc_completed

echo "Starting pod tests with a set name"
# In these cases we delete the pod at various points before the application completes.
# If the app has not completed, the signal handler will leave the cluster.
set_spark_sleep
run_app "bob"
del_pod "Didn't find cluster"
del_pod "Waiting for spark master"
del_pod "spark-submit"
del_pod "SparkContext: Starting job"
cleanup_app wait_for_cluster

# If the app has completed, the cluster will be deleted and restarting the app should create a new one.
clear_spark_sleep
run_app "bob"
del_pod_completed
cleanup_app wait_for_cluster

# Run the pod tests with a generated cluster name that should be re-used on pod restarts
echo "Starting pod tests with a generated name"
set_spark_sleep
run_app
del_pod "Didn't find cluster"
del_pod "Waiting for spark master"
del_pod "spark-submit"
del_pod "SparkContext: Starting job"
cleanup_app wait_for_cluster

clear_spark_sleep
run_app
del_pod_completed
cleanup_app wait_for_cluster 

# Run an app against a non-ephemeral cluster
echo Running dc tests with a non-ephemeral cluster
set_long_running
del_dc_non_ephemeral "spark-submit" "steve"
cleanup_cluster

echo Running pod tests with a non-ephemeral cluster
set_spark_sleep
set_test_mode # we want the signal handler to delay so that we can read the pod logs after the pod is deleted
run_app "steve"
clear_test_mode
del_pod_cluster_remains "spark-submit"
cleanup_app
cleanup_cluster

echo Running app completion test with a non-ephemeral cluster
clear_spark_sleep
run_app "steve"
app_completed_cluster_remains
cleanup_app 
cleanup_cluster

echo Running app completion test with scaled driver and ephemeral cluster
#  We may not have a clear use case for a scaled driver, but we can't stop it and
# so we should handle it
set_ephemeral
clear_spark_sleep
run_app "bob"
scaled_app_completed_cluster_remains
cleanup_app wait_for_cluster

echo Running redeploy test with ephemeral cluster
set_app_exit
set_spark_sleep
set_test_mode # we want the signal handler to delay so that we can read the pod logs after the pod is deleted
run_app "bob"
clear_test_mode
redeploy_cluster_removed
cleanup_app wait_for_cluster

os::cmd::expect_success 'oc delete project "$PROJECT"'
os::test::junit::declare_suite_end
oc project $ORIG_PROJECT
