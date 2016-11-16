#!/bin/bash

echo "version 1"

function app_exit {
    # Sleep forever so the process does not complete
    if [ ${APP_EXIT:-false} == false ]; then
        while true
        do
            sleep 5
        done
    else
        exit
    fi
}

# For JAR based applications (APP_MAIN_CLASS set), look for a single JAR file if APP_FILE
# is not set and use that. If there is not exactly 1 jar APP_FILE will remain unset.
# For Python applications, look for a single .py file
if [ -z "$APP_FILE" ]
then
    if [ -n "$APP_MAIN_CLASS" ]
    then
        cnt=$(cd $APP_ROOT/src/; ls -1 *.jar | wc -l)
        if [ "$cnt" -eq "1" ]
        then
            APP_FILE=$(cd $APP_ROOT/src/; ls *.jar)
        else
            echo "Error, no APP_FILE set and $cnt JAR file(s) found"
            app_exit
        fi
    else
        cnt=$(cd $APP_ROOT/src/; ls -1 *.py | wc -l)
        if [ "$cnt" -eq "1" ]
        then
            APP_FILE=$(cd $APP_ROOT/src/; ls *.py)
        else
            echo "Error, no APP_FILE set and $cnt py file(s) found"
            app_exit
        fi
    fi
fi

# Set up the env for the spark user
# This script is supplied by the python s2i base
source $APP_ROOT/etc/generate_container_user

if [ -z "${OSHINKO_CLUSTER_NAME}" ]; then
    OSHINKO_CLUSTER_NAME=cluster-`cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1`
fi

# Create the cluster through oshinko-rest if it does not exist
# The first line will say "creating" or "exists"
# The second line will be the number of workers
# The third line will be the url of the spark master
# The fourth line will be the url of the spark master webui
# Split the output by line and store in an array
SAVEIFS=$IFS; IFS=$'\n'
if [ -n "${OSHINKO_NAMED_CONFIG}" ]; then
    output=($($APP_ROOT/src/oshinko-get-cluster -create -config $OSHINKO_NAMED_CONFIG $OSHINKO_CLUSTER_NAME))
else
    output=($($APP_ROOT/src/oshinko-get-cluster -create $OSHINKO_CLUSTER_NAME))
fi
res=$?

# Build the spark-submit command and execute
if [ $res -eq 0 ] && [ -n "$output" ]
then
    IFS=$SAVEIFS
    desired=${output[1]}
    master=${output[2]}
    masterweb=${output[3]}

    # Now that we know what the master url is, export it so that the
    # app can use it if it likes.
    export OSHINKO_SPARK_MASTER=$master

    r=1
    while [ $r -ne 0 ]; do
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
    spark-submit $CLASS_OPTION --master $master $SPARK_OPTIONS $APP_ROOT/src/$APP_FILE $APP_ARGS

    if [ ${output[0]} == "creating" ] && [ ${OSHINKO_DEL_CLUSTER:-true} == true ]; then
        echo "Deleting cluster"
        $APP_ROOT/src/oshinko-get-cluster -delete $OSHINKO_CLUSTER_NAME
    fi
else
    echo "Error, output from oshinko-get-cluster follows:"
    echo "${output[*]}"
    IFS=$SAVEIFS
fi

app_exit
