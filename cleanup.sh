#!/bin/bash

if [ -d "${PWD}/configFiles" ]; then
    KUBECONFIG_FOLDER=${PWD}/configFiles
else
    echo "Configuration files are not found."
    exit
fi

kubectl delete -f ${KUBECONFIG_FOLDER}/createVolume-paid.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/createVolume.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/copyArtifactsJob.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/generateArtifactsJob.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/peersDeployment.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/create_channel.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/join_channel.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/chaincode_install.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/chaincode_instantiate.yaml

kubectl delete -f ${KUBECONFIG_FOLDER}/peerdebug.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/tooldebug.yaml

# kubectl delete --all pods --namespace=default