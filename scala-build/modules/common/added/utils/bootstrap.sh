#!/bin/bash
set -x

if [[ $@ == *"$STI_SCRIPTS_PATH"* ]]; then
   exec "$@"
else
   exec $SPARK_ROOT/kubernetes/dockerfiles/spark/bootstrap.sh "$@"
fi