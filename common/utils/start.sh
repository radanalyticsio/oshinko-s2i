#!/bin/bash

# Set up the env for the spark user
source $APP_ROOT/common.sh

# Create the cluster through oshinko-rest if it does not exist
# Return the spark master url as the last line of output in either case
output=$($APP_ROOT/oshinko-get-cluster $OSHINKO_CLUSTER_NAME $OSHINKO_REST)
res=$?

# Build the spark-submit command and execute
if [ $res -eq 0 ] && [ ! -z "$output" ]
then
    master=$(echo "$output" | tail -1)
    if [ -n "$APP_MAIN_CLASS" ]; then
        CLASS_OPTION="--class $APP_MAIN_CLASS"
    fi
    echo spark-submit $CLASS_OPTION --master $master $SPARK_OPTIONS $APP_ROOT/$APP_FILE $APP_ARGS
    spark-submit $CLASS_OPTION --master $master $SPARK_OPTIONS $APP_ROOT/$APP_FILE $APP_ARGS
else
    echo "$output"
fi

# Sleep forever so the process does not complete
if [ $FOREVER_LOOP ]
then
    while true
    do
        sleep 5
    done
fi
