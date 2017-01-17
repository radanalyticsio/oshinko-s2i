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
        exit 0
    fi
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

# Determine SPARK_CONF_DIR. If a non-empty config has been given then use it
ls -1 /etc/oshinko-spark-configs &> /dev/null
if [ $? -eq 0 ]; then
    sparkconfs=$(ls -1 /etc/oshinko-spark-configs | wc -l)
    if [ "${sparkconfs}" -ne "0" ]; then
        echo "Setting SPARK_CONF_DIR to /etc/oshinko-spark-configs"
        export SPARK_CONF_DIR=/etc/oshinko-spark-configs
    else
        echo "/etc/oshinko-spark-configs is empty, using default SPARK_CONF_DIR"
    fi
else
    echo "/etc/oshinko-spark-configs does not exist, using default SPARK_CONF_DIR"
fi

# This script is supplied by the python s2i base
source $APP_ROOT/etc/generate_container_user

if [ -z "${OSHINKO_CLUSTER_NAME}" ]; then
    OSHINKO_CLUSTER_NAME=cluster-`cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1`
fi

# Create the cluster through oshinko-cli if it does not exist
CLI=$APP_ROOT/src/oshinko-cli
CA="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
KUBE="$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT"
SA=`cat /var/run/secrets/kubernetes.io/serviceaccount/token`
CLI_ARGS="--certificate-authority=$CA --server=$KUBE --token=$SA"
CREATED=false

# See if the cluster already exists
line=$($CLI get $OSHINKO_CLUSTER_NAME $CLI_ARGS 2>&1)
res=$?
if [ "$res" -ne 0 ]; then
    echo "Didn't find cluster $OSHINKO_CLUSTER_NAME, creating..."
    line=$($CLI create $OSHINKO_CLUSTER_NAME --storedconfig=$OSHINKO_NAMED_CONFIG $CLI_ARGS 2>&1)
    res=$?
    if [ "$res" -eq 0 ]; then
        CREATED=true
        for i in {1..60}; do # wait up to 30 seconds
            line=$($CLI get $OSHINKO_CLUSTER_NAME $CLI_ARGS 2>&1)
            res=$?
            # If for some reason the get failed, keep trying
            # Since create reported success, it's extremely unlikely
            # that the get will ever fail but just in case ...
            if [ "$res" -eq 0 ]; then
                if [ -n "$line" ]; then
                    output=($(echo $line))
                    count=${output[1]}
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
    master=${output[2]}
    masterweb=${output[3]}

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
    spark-submit $CLASS_OPTION --master $master $SPARK_OPTIONS $APP_ROOT/src/$APP_FILE $APP_ARGS

    if [ "$CREATED" == true ] && [ ${OSHINKO_DEL_CLUSTER:-true} == true ]; then
        echo "Deleting cluster"
        line=$($CLI delete $OSHINKO_CLUSTER_NAME $CLI_ARGS 2>&1)
        if [ "$?" -ne 0 ]; then
           echo "Error, cluster deletion returned error, output from oshinko-cli:"
           echo "$line"
        fi
    fi
fi
app_exit
