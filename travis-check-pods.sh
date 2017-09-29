#!/bin/bash

oc login -u system:admin
oc project default

while true; do
    REG=$(oc get pod -l deploymentconfig=docker-registry --template='{{index .items 0 "status" "phase"}}')
    if [ "$?" -ne 0 -o "$REG" == "Error" ]; then
        echo "Registy pod is in error state..."
        exit 1
    fi
    if [ "$REG" == "Running" ]; then
        break
    fi
done

while true; do
    REG=$(oc get pod -l deploymentconfig=router --template='{{index .items 0 "status" "phase"}}')
    if [ "$?" -ne 0 -o "$REG" == "Error" ]; then
        echo "Router pod is in error state..."
        exit 1
    fi
    if [ "$REG" == "Running" ]; then
        break
    fi
done
echo "Registry and router pods are okay"
