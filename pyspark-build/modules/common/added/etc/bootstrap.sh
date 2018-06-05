#!/bin/bash
set -x

if [[ $@ == *"$STI_SCRIPTS_PATH"* ]]; then
   exec "$@"
else
   exec $APP_ROOT/etc/entrypoint.sh "$@"
fi
