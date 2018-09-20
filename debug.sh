#!/bin/bash

if [ -d "${PWD}/configFiles" ]; then
    KUBECONFIG_FOLDER=${PWD}/configFiles
else
    echo "Configuration files are not found."
    exit
fi

kubectl create -f ${KUBECONFIG_FOLDER}/peerdebug.yaml
kubectl create -f ${KUBECONFIG_FOLDER}/tooldebug.yaml

PEERDEBUG_NAME=$(kubectl get pods | grep "peerdebug" | awk '{print $1}')
TOOLDEBUG_NAME=$(kubectl get pods | grep "tooldebug" | awk '{print $1}')

echo "[INFO] peerdebug pod: ${PEERDEBUG_NAME}, tooldebug pod: ${TOOLDEBUG_NAME}"