# Creating a ClusterRole to Access a PV in Kubernetes

## Intro

You have been given access to a three-node cluster. Within that cluster, a PV has already been provisioned. You will need to make sure you can access the PV directly from a pod in your cluster. By default, pods cannot access PVs directly, so you will need to create a ClusterRole and test the access after it's been created. Every ClusterRole requires a ClusterRoleBinding to bind the role to a user, service account, or group. After you have created the ClusterRole and ClusterRoleBinding, try to access the PV directly from a pod. Perform the following tasks in order to complete this hands-on lab:

1. View the Persistent Volume using the kubectl command line tool.
2. Create a ClusterRole.
3. Create a ClusterRoleBinding.
4. Create a pod to access the PV.
5. Request access to the PV from the pod.

## View the Persistent Volume.

Use the following command to view the Persistent Volume within the cluster:

```kubectl get pv```

## Create a ClusterRole.
Use the following command to create the ClusterRole:

```kubectl create clusterrole pv-reader --verb=get,list --resource=persistentvolumes ```

## Create a ClusterRoleBinding.

Use the following command to create the ClusterRoleBinding:

```kubectl create clusterrolebinding pv-test --clusterrole=pv-reader --serviceaccount=web:default```

## Create a pod to access the PV.

1. Use the following YAML to create a pod that will proxy the connection and allow you to curl the address:
```
 apiVersion: v1
 kind: Pod
 metadata:
   name: curlpod
   namespace: web
 spec:
   containers:
   - image: tutum/curl
     command: ["sleep", "9999999"]
     name: main
   - image: linuxacademycontent/kubectl-proxy
     name: proxy
   restartPolicy: Always
```

2. Use the following command to create the pod:

```kubectl apply -f curlpod.yaml```

## Request access to the PV from the pod.

1. Use the following command (from within the pod) to access a shell from the pod:

```kubectl exec -it curlpod -n web -- sh```

2. Use the following command to curl the PV resource:

```curl localhost:8001/api/v1/persistentvolumes```