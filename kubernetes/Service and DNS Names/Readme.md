# Deploying a Service and Resolving DNS Names

## Additional Information and Resources

You have been given a three-node cluster. Within that cluster, you must perform the following tasks in order to create a service and resolve the DNS names for that service. You will create the necessary Kubernetes resources in order to perform this DNS query. To adequately complete this hands-on lab, you must have a working deployment, a working service, and be able to record the DNS name of the service within your Kubernetes cluster. This means you will perform the following tasks:

1. Create an nginx deployment using the latest nginx image.
2. Verify the deployment has been created successfully.
3. Create a service from the nginx deployment created in the previous objective.
4. Verify the service has been created successfully.
5. Create a pod that will allow you to perform the DNS query.
6. Verify that the pod has been created successfully.
7. Perform the DNS query to the service created in an earlier objective.
9. Record the DNS name of the service.

## Create an nginx deployment, and verify it was successful.

###Use this command to create an nginx deployment:

```kubectl run nginx --image=nginx```

Use this command to verify deployment was successful:

```kubectl get deployments```

## Create a service, and verify the service was successful.

### Use this command to create a service:

```kubectl expose deployment nginx --port 80 --type NodePort```

Use this command to verify the service was created:

```kubectl get services```

## Create a pod that will allow you to query DNS, and verify it’s been created.

### Use the following YAML to create the busybox pod spec:
```
apiVersion: v1
kind: Pod
metadata:
  name: busybox
spec:
  containers:
  - image: busybox:1.28.4
    command:
      - sleep
      - "3600"
    name: busybox
  restartPolicy: Always
```

Use the following command to create the busybox pod:

```kubectl create -f busybox.yaml```

Use the following command to verify the pod was created successfully:

```kubectl get pods```

## Perform a DNS query to the service.

### Use the following command to query the DNS name of the nginx service:

```kubectl exec busybox -- nslookup nginx```

## Record the DNS name.

Record the name of:

```<service-name>;.default.svc.cluster.local```