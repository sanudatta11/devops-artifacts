# Deploy a Service in Kubernetes from LinuxAcademy

## Create a deployment for the store-products service with four replicas.

### Log in to the Kube master node.
### Create the deployment with four replicas:
```
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: store-products
  labels:
    app: store-products
spec:
  replicas: 4
  selector:
    matchLabels:
      app: store-products
  template:
    metadata:
      labels:
        app: store-products
    spec:
      containers:
      - name: store-products
        image: linuxacademycontent/store-products:1.0.0
        ports:
        - containerPort: 80
EOF
```

## Create a store-products service and verify that you can access it from the busybox testing pod.

### Create a service for the store-products pods:
```
cat << EOF | kubectl apply -f -
kind: Service
apiVersion: v1
metadata:
  name: store-products
spec:
  selector:
    app: store-products
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
EOF
```
### Make sure the service is up in the cluster:
```kubectl get svc store-products```

The output will look something like this:
```
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
store-products   ClusterIP   10.104.11.230   <none>        80/TCP    59s
```
### Use kubectl exec to query the store-products service from the busybox testing pod.
```
kubectl exec busybox -- curl -s store-products
```