#!/bin/sh
set -ex

TAG=`git describe --tags --abbrev=0 2> /dev/null | head -n1`
if [ -z $TAG ]; then
    TAG='0.0.0'
fi

APP=oshinko-get-cluster

if [ $1 = build ]; then
    OUTPUT_FLAG="-o _output/oshinko-get-cluster"
fi

if [ $1 = test ]; then
    TARGET=./tests
    GO_OPTIONS=-v
else
    TARGET=./oshinko-get-cluster.go
fi

# this export is needed for the vendor experiment for as long as go version
# 1.5 is still in use.
export GO15VENDOREXPERIMENT=1

go $1 $GO_OPTIONS $OUTPUT_FLAG $TARGET
