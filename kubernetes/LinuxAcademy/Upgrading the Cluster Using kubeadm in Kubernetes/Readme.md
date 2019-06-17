# Upgrading the Kubernetes Cluster Using kubeadm

## Description

In this hands-on lab, we will be presented with a three-node cluster. We must upgrade the cluster components to version 1.13.5. In order to accomplish this, we will need to utilize the kubeadm tool to upgrade the components in the correct order, and then also upgrade the kubelet on each server individually. We will then run the kubectl get nodes command to verify the nodes are all successfully updated. Additionally, we will upgrade to the latest version of kubectl.

## Get version 1.13.5 of kubeadm

Use the following commands to create a variable and get the latest version of kubeadm:

```
export VERSION=v1.13.5
export ARCH=amd64
curl -sSL https://dl.k8s.io/release/${VERSION}/bin/linux/${ARCH}/kubeadm > kubeadm
```

## Install kubeadm and verify it has been installed correctly.

Run the following commands to install kubeadm and verify the version:

```
sudo install -o root -g root -m 0755 ./kubeadm /usr/bin/kubeadm
sudo kubeadm version
```

## Plan the upgrade in order to check for errors.

Use the following command to plan the upgrade:

```sudo kubeadm upgrade plan```

## Perform the upgrade of the kube-scheduler and kube-controller-manager.

Use this command to apply the upgrade (also in the output of upgrade plan):

```sudo kubeadm upgrade apply v1.13.5```

## Get the latest version of kubelet.

Use the following commands to get the latest version of kubelet on each node:

```
export VERSION=v1.13.5
export ARCH=amd64
curl -sSL https://dl.k8s.io/release/${VERSION}/bin/linux/${ARCH}/kubelet > kubelet
```

## Install kubelet on each node and restart the kubelet service.

Use these commands to install kubelet and restart the kubelet service:

```
sudo install -o root -g root -m 0755 ./kubelet /usr/bin/kubelet
sudo systemctl restart kubelet.service
```

## Verify the kubelet was installed correctly.

Use the following command to verify the kubelet was installed correctly:

```kubectl get nodes```

## Get version 1.13.5 of kubectl

Use the following command to get the latest version of kubectl:

```curl -sSL https://dl.k8s.io/release/${VERSION}/bin/linux/${ARCH}/kubectl > kubectl```

## Upgrade kubectl

Use the following command to install the latest version of kubectl:

```sudo install -o root -g root -m 0755 ./kubectl /usr/bin/kubectl```