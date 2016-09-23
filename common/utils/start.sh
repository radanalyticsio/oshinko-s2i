#!/bin/bash

echo "version 1"

# Set up the env for the spark user
# This script is supplied by the python s2i base
source $APP_ROOT/etc/generate_container_user

if [ -z ${OSHINKO_CLUSTER_NAME} ]; then
    OSHINKO_CLUSTER_NAME=cluster-`cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1`
fi

# Create the cluster through oshinko-rest if it does not exist
# First line will say "creating" if it is creating the cluster
# Second line will be the url of the spark master
output=($($APP_ROOT/src/oshinko-get-cluster -create $OSHINKO_CLUSTER_NAME))
res=$?

# Build the spark-submit command and execute
if [ $res -eq 0 ] && [ ! -z "$output" ]
then
    # Since we called for create, then we are either going to get "Creating" or "Exists"
    # followed by the worker count, the master url, and the master web url
    desired=${output[1]}
    master=${output[2]}
    masterweb=${output[3]}

    # Now that we know what the master url is, export it so that the
    # app can use it if it likes.
    export OSHINKO_SPARK_MASTER=$master

    r=1
    while [ $r -ne 0 ]; do
        echo "Waiting for spark master to be available ..."
        curl --connect-timeout 4 -s -X GET $masterweb > /dev/null
        r=$?
        sleep 1
    done

    while true; do
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
    spark-submit $CLASS_OPTION --master $master $SPARK_OPTIONS $APP_ROOT/src/$APP_FILE $APP_ARGS


    if [ ${output[0]} == "creating" ] && [ ${OSHINKO_DEL_CLUSTER:-true} == true ]; then
        echo "Deleting cluster"
        $APP_ROOT/src/oshinko-get-cluster -delete $OSHINKO_CLUSTER_NAME
    fi
else
    echo "$output"
fi

# Sleep forever so the process does not complete
if [ ${APP_EXIT:-false} == false ]; then
    while true
    do
        sleep 5
    done
fi
