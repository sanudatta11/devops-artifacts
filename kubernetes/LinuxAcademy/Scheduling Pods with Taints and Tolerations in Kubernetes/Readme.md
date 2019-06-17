#Scheduling Pods with Taints and Tolerations in Kubernetes

## Additional Information and Resources
You have been given a three-node cluster. Within that cluster, you must perform the following tasks to taint the production node in order to repel work. You will create the necessary taint to properly label one of the nodes “prod.” Then you will deploy two pods — one to each environment. One pod spec will contain the toleration for the taint. You must perform the following tasks in order to complete this hands-on lab:

Taint one of the worker nodes to identify the prod environment.
Create the YAML spec for a pod that will be scheduled to the dev environment.
Create the YAML spec for a pod that will be scheduled to the prod environment.
Deploy each pod to their respective environments.
Verify each pod has been scheduled successfully to each environment.

## Taint one of the worker nodes to repel work.

### Use the following command to taint the node:

```
kubectl taint node <node_name> node-type=prod:NoSchedule
```

## Schedule a pod to the dev environment.

### Use the following YAML to specify a pod that will be scheduled to the dev environment:
```
apiVersion: v1
kind: Pod
metadata:
 name: dev-pod
 labels:
   app: busybox
spec:
 containers:
 - name: dev
   image: busybox
   command: ['sh', '-c', 'echo Hello Kubernetes! && sleep 3600']
```
Use the following command to create the pod:
```
kubectl create -f dev-pod.yaml
```

## Allow a pod to be scheduled to the prod environment.

### Use the following YAML to create a deployment and a pod that will tolerate the prod environment:
```
apiVersion: apps/v1
kind: Deployment
metadata:
 name: prod
spec:
 replicas: 1
 selector:
   matchLabels:
     app: prod
 template:
   metadata:
     labels:
       app: prod
   spec:
     containers:
     - args:
       - sleep
       - "3600"
       image: busybox
       name: main
     tolerations:
     - key: node-type
       operator: Equal
       value: prod
       effect: NoSchedule
```
### Use the following command to create the pod:
```
kubectl create -f prod-deployment.yaml
```

## Verify each pod has been scheduled and verify the toleration.

### Use the following command to verify the pods have been scheduled:
```
kubectl get pods -o wide
```

### Verify the toleration of the production pod:

```kubectl get pods <pod_name> -o yaml```