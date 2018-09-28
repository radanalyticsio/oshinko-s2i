#!/bin/bash

function handle_term {
    echo Received a termination signal

    local cnt
    local killed=1
    if [ -n "$PID" ]; then
        echo "Stopping subprocess $PID"
        kill -TERM $PID
        for cnt in {1..10}
        do
            kill -0 $PID >/dev/null 2>&1
            if [ "$?" -ne 0 ]; then
                killed=0
                break
            else
                sleep 1
            fi
        done
        if [ "$killed" -ne 0 ]; then
            echo Process is still running 10 seconds after TERM, sending KILL
            kill -9 $PID
        fi
        wait $PID
        echo "Subprocess stopped"
    fi
    exit 0
}

if [[ $@ == *"$STI_SCRIPTS_PATH"* ]]; then
   exec "$@"
else
   trap handle_term TERM INT
   $SPARK_INSTALL/entrypoint.sh "$@" &
   PID=$!
   wait $PID
fi
