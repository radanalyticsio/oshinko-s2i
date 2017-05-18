#!/bin/bash
trap handle_term TERM INT

echo "version 1"

function app_exit {
    # Sleep forever so the process does not complete
    while [ ${APP_EXIT:-false} == false ]
    do
        sleep 1
    done
    exit 0
}

function check_reverse_proxy {
    grep -e "^spark\.ui\.reverseProxy" $SPARK_HOME/conf/spark-defaults.conf &> /dev/null
    if [ "$?" -ne 0 ]; then
        echo "Appending default reverse proxy config to spark-defaults.conf"
        echo "spark.ui.reverseProxy              true" >> $SPARK_HOME/conf/spark-defaults.conf
        echo "spark.ui.reverseProxyUrl           /" >> $SPARK_HOME/conf/spark-defaults.conf
    fi
}

function get_deployment_config {
    DEPLOYMENT_CONFIG=$(grep "^deploymentconfig=" /etc/podinfo/labels | cut -d'=' -f2- | tr -d '"')
}

function get_deployment {
    DEPLOYMENT=$(grep "^deployment=" /etc/podinfo/labels | cut -d'=' -f2- | tr -d '"')
}
get_deployment

function delete_ephemeral {
    local appstatus=$1
    echo "Deleting cluster $OSHINKO_CLUSTER_NAME"
    line=$($CLI delete $OSHINKO_CLUSTER_NAME --app=$POD_NAME --app-status=$1 $CLI_ARGS 2>&1)
    echo $line
}

function handle_term {
    echo Received a termination signal
    # If we've saved a PID for a subprocess, kill that first before
    # trying to delete the cluster
    if ! [ -z ${PID+x} ]; then
        echo "Stopping subprocess $PID"
        kill -TERM $PID
        wait $PID
        echo "Subprocess stopped"
    fi

    # Tell delete_ephemeral that we are calling because of a signal received
    # before or during the spark-submit call.
    delete_ephemeral terminated
    if [  ${TEST_MODE:-false} == true ]; then
        echo Test mode delaying 10 seconds before exit
        sleep 10
    fi
    exit 0
}

function exit_flag {
    # Set APP_EXIT to true and ignore the signal, so the normal loop will fall out
    echo Received a termination signal
    if [  ${TEST_MODE:-false} == true ]; then
        echo Test mode delaying 10 seconds before exit
        sleep 10
    fi
    echo Setting app_exit true on signal handler
    APP_EXIT=true
}


# For JAR based applications (APP_MAIN_CLASS set), look for a single JAR file if APP_FILE
# is not set and use that. If there is not exactly 1 jar APP_FILE will remain unset.
# For Python applications, look for a single .py file
if [ -z "$APP_FILE" ]; then
    if [ -n "$APP_MAIN_CLASS" ]; then
        cnt=$(cd $APP_ROOT/src/; ls -1 *.jar | wc -l)
        if [ "$cnt" -eq "1" ]; then
            APP_FILE=$(cd $APP_ROOT/src/; ls *.jar)
        else
            echo "Error, no APP_FILE set and $cnt JAR file(s) found"
            app_exit
        fi
    else
        cnt=$(cd $APP_ROOT/src/; ls -1 *.py | wc -l)
        if [ "$cnt" -eq "1" ]; then
            APP_FILE=$(cd $APP_ROOT/src/; ls *.py)
        else
            echo "Error, no APP_FILE set and $cnt py file(s) found"
            app_exit
        fi
    fi
fi

# This script is supplied by the python s2i base
source $APP_ROOT/etc/generate_container_user

# Create the cluster through oshinko-cli if it does not exist
CLI=$APP_ROOT/src/oshinko-cli
CA="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"

if [ "$KUBERNETES_SERVICE_PORT" -eq 443 ]; then                                                                                                           
    KUBE_SCHEME="https"                                                                                                                                   
else                                                                                                                                                      
    KUBE_SCHEME="http"                                                                                                                                    
fi                                                                                                                                                        
KUBE="$KUBE_SCHEME://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT"

SA=`cat /var/run/secrets/kubernetes.io/serviceaccount/token`
NS=`cat /var/run/secrets/kubernetes.io/serviceaccount/namespace`
CLI_ARGS="--certificate-authority=$CA --server=$KUBE --token=$SA --namespace=$NS"

if [ -z "${OSHINKO_CLUSTER_NAME}" ]; then
    lookup=$($CLI get --app=$DEPLOYMENT $CLI_ARGS 2>&1)
    if [ "$?" -eq 0 ]; then
        output=($(echo $lookup))
        OSHINKO_CLUSTER_NAME=${output[0]}
        echo using stored cluster name $OSHINKO_CLUSTER_NAME
    else
        OSHINKO_CLUSTER_NAME=cluster-`cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1`
    fi
fi

# If a spark driver configmap has been named, use the cli to get it
# and the helper process-driver-config to write the files to SPARK_HOME/conf
if [ -n "$OSHINKO_SPARK_DRIVER_CONFIG" ]; then
    echo "Looking for spark driver config files in configmap $OSHINKO_SPARK_DRIVER_CONFIG"
    tmpfile=$(mktemp)
    $($CLI configmap $OSHINKO_SPARK_DRIVER_CONFIG $CLI_ARGS -o json > $tmpfile)
    if [ "$?" -eq 0 ]; then
        $APP_ROOT/src/process-driver-config $tmpfile
        if [ "$?" -eq 0 ]; then
            echo "Spark configuration updated"
        fi
    else
        echo "Unable to read spark driver config $OSHINKO_SPARK_DRIVER_CONFIG"
    fi
    rm $tmpfile
fi

# As a final check on spark config, add the reverse proxy settings if
# the configuration does not already contain values for them
check_reverse_proxy

# See if the cluster already exists
line=$($CLI get $OSHINKO_CLUSTER_NAME $CLI_ARGS 2>&1)
res=$?
if [ "$res" -ne 0 ]; then
    if [ ${OSHINKO_DEL_CLUSTER:-true} == true ]; then
        echo "Didn't find cluster $OSHINKO_CLUSTER_NAME, creating ephemeral cluster" 
        APP_FLAG="--app=$POD_NAME --ephemeral"
    else
        echo "Didn't find cluster $OSHINKO_CLUSTER_NAME, creating long-running cluster"
        APP_FLAG="--app=$POD_NAME"
    fi
    line=$($CLI create $OSHINKO_CLUSTER_NAME --storedconfig=$OSHINKO_NAMED_CONFIG $APP_FLAG $CLI_ARGS 2>&1)
    res=$?
    if [ "$res" -eq 0 ]; then
        for i in {1..60}; do # wait up to 30 seconds
            line=$($CLI get $OSHINKO_CLUSTER_NAME $CLI_ARGS 2>&1)
            res=$?
            # If for some reason the get failed, keep trying
            # Since create reported success, it's extremely unlikely
            # that the get will ever fail but just in case ...
            if [ "$res" -eq 0 ]; then
                if [ -n "$line" ]; then
                    output=($(echo $line))
                    count=${output[2]}
                    # Empirically, worker count will jump from 0 to
                    # full number of workers when the pods are initialized
                    # without any intermediate counts. Verify this in kube
                    # code (or community)
                    if [ "$count" -ne 0 ]; then
                        break
                    fi
                else
                    # uh oh, cli is broken, success but no output
                    break
                fi
            fi
            sleep 0.5
        done
    fi
else
    echo "Found cluster $OSHINKO_CLUSTER_NAME"
fi

# If res is not 0 then create or get failed (possibly repeatedly)
if [ "$res" -ne 0 ]; then
    echo "Error, unable to find or create cluster, output from oshinko-cli:"
    echo "$line"

# Just in case a change breaks the CLI, test for output
elif [ -z "$line" ]; then
    echo "Error, the cli returned success on 'get' but gave no output, giving up"

else
    # Build the spark-submit command and execute
    output=($(echo $line))
    desired=${output[1]}
    master=${output[3]}
    masterweb=${output[4]}
    ephemeral=${output[6]}

    if [ "$ephemeral" != "$DEPLOYMENT" -a "$ephemeral" != "shared" ]; then
        echo "error, ephemeral cluster belongs to deployment "$ephemeral" and this is "$DEPLOYMENT", exiting"
        app_exit
    fi
    if [ "$ephemeral" == "shared" ]; then
        echo Using long-running cluster $OSHINKO_CLUSTER_NAME
    else
        echo Using ephemeral cluster $OSHINKO_CLUSTER_NAME
    fi

    # Now that we know what the master url is, export it so that the
    # app can use it if it likes.
    export OSHINKO_SPARK_MASTER=$master

    r=1
    while [ "$r" -ne 0 ]; do
        echo "Waiting for spark master $masterweb to be available ..."
        curl --connect-timeout 4 -s -X GET $masterweb > /dev/null
        r=$?
        sleep 1
    done

    while true; do
        # Scrape the master web UI for the number of alive workers
        # This may be replaced with something based on metrics ...
        workers=$(curl -s -X GET $masterweb | grep -e "[Aa]live.*[Ww]orkers")
        cnt=($(echo $workers | sed "s,[^0-9],\\ ,g"))
        if [ ${cnt[-1]} -eq "$desired" ]; then
	    break
	fi
        echo "Waiting for spark workers (${cnt[-1]}/$desired alive) ..."
        sleep 5
    done
    echo "All spark workers alive"

    if [ -n "$APP_MAIN_CLASS" ]; then
        CLASS_OPTION="--class $APP_MAIN_CLASS"
    fi
    echo spark-submit $CLASS_OPTION --master $master $SPARK_OPTIONS $APP_ROOT/src/$APP_FILE $APP_ARGS
    spark-submit $CLASS_OPTION --master $master $SPARK_OPTIONS $APP_ROOT/src/$APP_FILE $APP_ARGS &
    PID=$!
    wait $PID

    # At this point the subprocess completed and we are about to clean up the cluster.
    # Switch to a signal handler that just sets a flag, so that we can delete the cluster
    # without interruption and then loop in app_exit depending on the settings. app_exit
    # will return if the flag is changed by the signal handler.

    # Note that the cluster MUST be cleaned up here, because once this pod exits there is not
    # guaranteed to be an agent to do cleanup.  Consider the case of a job, where no new instance
    # of this driver will be scheduled, or the case of a dc where the dc is deleted while the pod
    # is in the COMPLETED or crash loop backoff state. The cluster would be orhpaned. So, since the
    # app completed, we take the cluster with us, as long as our repl count is 0 or 1 (if it's more
    # then someone scaled the driver and we have to leave the cluster anyway).
    trap exit_flag TERM INT
    delete_ephemeral completed
fi
app_exit
