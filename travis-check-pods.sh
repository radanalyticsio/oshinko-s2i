#!/bin/bash

oc login -u system:admin
oc project default

while true; do
    REG=$(oc get pod -l deploymentconfig=docker-registry --template='{{index .items 0 "status" "phase"}}')
    if [ "$?" -eq 0 ]; then
        break
    fi
    echo "Waiting for registry pod"
    sleep 10
done

while true; do
    REG=$(oc get pod -l deploymentconfig=docker-registry --template='{{index .items 0 "status" "phase"}}')
    if [ "$?" -ne 0 -o "$REG" == "Error" ]; then
        echo "Registy pod is in error state..."
        exit 1
    fi
    if [ "$REG" == "Running" ]; then
        break
    fi
    sleep 5
done

while true; do
    REG=$(oc get pod -l deploymentconfig=router --template='{{index .items 0 "status" "phase"}}')
    if [ "$?" -eq 0 ]; then
        break
    fi
    echo "Waiting for registry pod"
    sleep 10
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
    sleep 5
done
echo "Registry and router pods are okay"
