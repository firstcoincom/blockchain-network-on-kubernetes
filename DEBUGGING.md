Troubleshooting
===============

* Always start your network fresh. Use the script `deleteNetwork.sh` to delete any pre-existing jobs/pods etc.

* If you see below error, then environment is not set properly and therefore kubectl commands will not work.
  ```
  $ kubectl get pods
  The connection to the server localhost:8080 was refused - did you specify the right host or port?
  ```
  
* If you see below error, it means this peer has not joined the channel and so your query will not work.

  ![](images/error1.png)
  
* If you see something similar to the following:

  ![](images/error2.png)
  
  It shows there is some error in command. For example, in this snapshot `-c` is missing before passing arguments.
  
* If you see the below error,

  ![](images/error3.png)
  
  There is something wrong with the setup. You would like to do setup from a fresh.
  
* For debugging purposes, if you want to inspect the logs of any container, then run the following command.

  ```
   $ kubectl get pods --show-all                  # Get the name of the pod
   $ kubectl logs [pod name]                      # if pod has one container
   $ kubectl logs [pod name] [container name]     # if pod has more than one container
  ```
  
* If you see something like this for chaincode instantiation,

  ![](images/error4.png)
  
  It means chaincode has been instantiated already on the peer. Retrying of the same will fail with this error. You can ignore
  this message and continue with your transactions (invoke/query).
  
* If you see error as shown below:

  ![](images/error5.png)

  It is intermittent issue and might occur because of network. Delete the network and retry afresh after sometime. 

* on Google Cloud, depending on your cluster setting you might get `Pod status unscheduled, insufficient CPU`
  Either lower CPU required or just add more nodes to the cluster

# Deploy the Hyperledger Blockchain network using Kubernetes APIs on AWS Cloud

This is an extension of the Hyperledger Fabric network using [IBM Blockchain on Kubernetes](https://github.com/IBM/blockchain-network-on-kubernetes). Before you run the IBM setup script. Please run through the steps below.

## Prepare your Lambo cluster

Provision a Kubernetes cluster using the [createcluster.sh](createcluster.sh) script.

## Prepare AWS EFS - Extended Filesystem

The IBM deployment depends on a Persistent Volume (/shared) to distribute the configuration files across orderer, peers, and ca nodes. This requires a PVC with **Access Modes: ReadWriteMany** However, this mode is not supported on [AWS EBS backed storage](https://github.com/gardener/gardener/issues/98). One possible solutions is to use AWS EFS as storage for the PV.

### Creating an EFS

![](images/aws-efs.png)

1. Launch the EFS service **Storage->EFS**

![](images/aws-efs1.png)

2. Select the VPC for your cluster
3. Make sure the EFS partition is attach to all your availability zones

![](images/aws-efs2.png)

4. Leave default settings

![](images/aws-efs3.png)

5. Review and create your EFS partition

![](images/aws-efsfinal.png)

6. Make note of the EFS DNS name. The first portion is the filesystem ID that we will need in the next step. The second is the EFS region.

7. Open the file [efsConfigMap.yaml](configFiles/efsConfigMap.yaml)

The ConfigMap creates an efs-provisioner which allow you to mount EFS storage as PersistentVolumes in kubernetes. It consists of a container that has access to an AWS EFS resource. The container reads a configmap which contains the EFS filesystem ID from the previous steps, the AWS region and the name you want to use for your efs-provisioner. This name will be used later when you create a storage class.

Update the file.system.id and aws.region with the info from the previous step.
```
data:
  file.system.id: fs-d2294b7b
  aws.region: us-west-2
  provisioner.name: firstcoin.io/aws-efs
```

## Create new Storage Class

In order for the PV to recognize EFS we need to provision a new Storage Class.

1. Create a new provisioner
```
kubectl create -f configFiles/efsConfigMap.yaml
```

2. Next, create a new Storage Class using the **firstcoin.io/aws-efs** provisioner
```
kubectl create -f configFiles/aws-efs-sc.yaml
```

## Start Deploying

You can now start the IBM deployment process. Follow the instructions from the [IBM Repo](https://github.com/IBM/blockchain-network-on-kubernetes/) repo. Let the [setup_blockchainNetwork.sh] (https://github.com/IBM/blockchain-network-on-kubernetes/blob/master/setup_blockchainNetwork.sh) script run. It will very likely fail at the create or join channel stages.

# Hack
The IBM script does a lot of waiting and spinning. Also, the EFS mount does not always work and the pods end up using its own volume for the **/shared** PVC. Use the hack below.

We will need to manually copy the pre-generated genesis.block and assets to the pods.

1. Start the two debug pods.

Hyperledger tools
```
kubectl create -f configFiles/tooldebug.yaml
```

Hyperledger peers
```
kubectl create -f configFiles/peerdebug.yaml
```

2. Copy the files to the pods.
```
cd shared
kubectl cp . <pod_name>:/shared
```

3. Check to make sure all the files are in the pod

```
kubectl exec -it <pod_name> bash
```

This should do it. Manually re-run the create and join channel jobs again.

```
kubectl delete -f configFiles/create_channel.yaml
kubectl delete -f configFiles/join_channel.yaml

kubectl create -f configFiles/create_channel.yaml
kubectl create -f configFiles/join_channel.yaml
```


# Debugging Tools
The IBM script does a lot of waiting and spinning. Also, the EFS mount does not always work and the pods end up using its own volume for the **/shared** PVC. Use the hack below.

We will need to manually copy the pre-generated genesis.block and assets to the pods.

1. Start the two debug pods.

Hyperledger tools
```
kubectl create -f configFiles/tooldebug.yaml
```

Hyperledger peers
```
kubectl create -f configFiles/peerdebug.yaml
```

2. Copy the files to the pods.
```
cd shared
kubectl cp . <pod_name>:/shared
```

3. Check to make sure all the files are in the pod

```
kubectl exec -it <pod_name> bash
```

This should do it. Manually re-run the create and join channel jobs again.

```
kubectl delete -f configFiles/create_channel.yaml
kubectl delete -f configFiles/join_channel.yaml

kubectl create -f configFiles/create_channel.yaml
kubectl create -f configFiles/join_channel.yaml
```

