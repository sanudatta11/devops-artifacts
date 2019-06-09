# Rolling Updated in Kubnernetes

## Additional Information and Resources
You have been given a three-node cluster. Within that cluster, you must deploy your application and then successfully update the application to a new version without causing any downtime. You will use the image linuxacademycontent/kubeserve:v1, which will serve as your application. You must perform the steps to verify your app successfully rolled out initially; create a service for your deployment, so it can be used by the end user; and then perform the update, verifying that the update did not experience any service interruption for your end users. You must perform the following tasks in order to complete this hands-on lab:

1. Create and roll out a deployment, and verify the deployment was successful.
2. Verify the application is using the correct version.
3. Scale up your application to create high availability.
4. Create a service from your deployment, so users can access your application.
5. Perform a rolling update to version 2 of the application.
6. Verify the app is now at version 2 and there was no downtime to end users.

## Create and roll out version 1 of the application, and verify a successful deployment.

### Use the following YAML named kubeserve-deployment.yaml to create your deployment:
```
 apiVersion: apps/v1
 kind: Deployment
 metadata:
   name: kubeserve
 spec:
   replicas: 3
   selector:
     matchLabels:
       app: kubeserve
   template:
     metadata:
       name: kubeserve
       labels:
         app: kubeserve
     spec:
       containers:
       - image: linuxacademycontent/kubeserve:v1
         name: app
```

### Use the following command to create the deployment:

```
kubectl apply -f kubeserve-deployment.yaml --record
```

### Use the following command to verify the deployment was successful:

```
kubectl rollout status deployments kubeserve
```

### Use the following command to verify the app is at the correct version:
```
kubectl describe deployment kubeserve
```

## Scale up the application to create high availability.

### Use the following command to scale up your application to five replicas:

```
kubectl scale deployment kubeserve --replicas=5
```

### Use the following command to verify the additional replicas have been created:
```kubectl get pods```

## Create a service, so users can access the application.

### Use the following command to create a service for your deployment:

```kubectl expose deployment kubeserve --port 80 --target-port 80 --type NodePort```

### Use the following command to verify the service is present and collect the cluster IP:

```kubectl get services```
### Use the following command to verify the service is responding:

```curl http://<ip-address-of-the-service>```

## Perform a rolling update to version 2 of the application, and verify its success.

### Use this curl loop command to see the version change as you perform the rolling update:

 ```while true; do curl http://<ip-address-of-the-service>; done```

### Use this command to perform the update (while the curl loop is running):

 ```kubectl set image deployments/kubeserve app=linuxacademycontent/kubeserve:v2 --v 6```

### Use this command to view the additional ReplicaSet created during the update:

 ```kubectl get replicasets```
### Use this command to verify all pods are up and running:

 ```kubectl get pods```
### Use this command to view the rollout history:

 ```kubectl rollout history deployment kubeserve```