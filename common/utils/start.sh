#!/bin/bash

echo "version 1"

# Set up the env for the spark user
source $APP_ROOT/common.sh

# Create the cluster through oshinko-rest if it does not exist
# First line will say "creating" if it is creating the cluster
# Second line will be the url of the spark master
# If OSHINKO_REST is defined it will be used, otherwise the env will be scanned to find the rest server
output=($($APP_ROOT/oshinko-get-cluster -create -server=$OSHINKO_REST $OSHINKO_CLUSTER_NAME))
res=$?

# Build the spark-submit command and execute
if [ $res -eq 0 ] && [ ! -z "$output" ]
then
    # Since we called for create, then we are either going to get "Creating" or "Exists"
    # followed by the worker count and the master url
    r=1
    while [ $r -ne 0 ]; do
        echo "Waiting for spark master to be available ..."
        curl --connect-timeout 4 -s -X GET http://"$OSHINKO_CLUSTER_NAME"-ui:8080 > /dev/null
        r=$?
        sleep 1
    done

    desired=${output[1]}
    while true; do
        workers=$(curl -s -X GET http://"$OSHINKO_CLUSTER_NAME"-ui:8080 | grep -e "[Aa]live.*[Ww]orkers")
        cnt=($(echo $workers | sed "s,[^0-9],\\ ,g"))
        if [ ${cnt[-1]} -eq "$desired" ]; then
	    break
	fi
        echo "Waiting for spark workers (${cnt[-1]}/$desired alive) ..."
        sleep 5
    done
    echo "All spark workers alive"

    master=${output[2]}
    if [ -n "$APP_MAIN_CLASS" ]; then
        CLASS_OPTION="--class $APP_MAIN_CLASS"
    fi
    echo spark-submit $CLASS_OPTION --master $master $SPARK_OPTIONS $APP_ROOT/$APP_FILE $APP_ARGS
    spark-submit $CLASS_OPTION --master $master $SPARK_OPTIONS $APP_ROOT/$APP_FILE $APP_ARGS

    if [ ${output[0]} == "creating" ] && [ "${OSHINKO_DEL_CLUSTER}" == "yes" ]; then
        echo "Deleting cluster"
        $APP_ROOT/oshinko-get-cluster -delete -server=$OSHINKO_REST $OSHINKO_CLUSTER_NAME
    fi
else
    echo "$output"
fi

# Sleep forever so the process does not complete
if [ -n "${FROM_DEPLOYMENTCONFIG+x}" ]
then
    while true
    do
        sleep 5
    done
fi
