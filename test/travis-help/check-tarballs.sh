#!/bin/bash

top=$(git rev-parse --show-toplevel)
find $top -regextype posix-egrep -regex '.*\.(tar\.gz|tgz)' | $top/test/repo-checks/check-zero.sh
