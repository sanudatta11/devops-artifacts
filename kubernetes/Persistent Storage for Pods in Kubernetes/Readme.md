# Persistent Volume Testing in Kubernetes

## Create a PersistentVolume

### Use the following YAML spec for the PersistentVolume named mongodb-pv.yaml:
```
 apiVersion: v1
 kind: PersistentVolume
 metadata:
   name: mongodb-pv
 spec:
   storageClassName: local-storage
   capacity:
     storage: 1Gi
   accessModes:
     - ReadWriteOnce
   hostPath:
     path: "/mnt/data"
```

### Then, create the PersistentVolume:

```kubectl apply -f mongodb-pv.yaml```

## Create a PersistentVolumeClaim.

### Use the following YAML spec for the PersistentVolumeClaim named mongodb-pvc.yaml:
```
 apiVersion: v1
 kind: PersistentVolumeClaim
 metadata:
   name: mongodb-pvc
 spec:
   storageClassName: local-storage
   accessModes:
     - ReadWriteOnce
   resources:
     requests:
       storage: 1Gi
```
### Then, create the PersistentVolumeClaim:

 ```kubectl apply -f mongodb-pvc.yaml```

## Create a pod from the mongodb image, with a mounted volume to mount path 
**`/data/db`.**

### Use the following YAML spec for the pod named mongodb-pod.yaml:

```
 apiVersion: v1
 kind: Pod
 metadata:
   name: mongodb 
 spec:
   containers:
   - image: mongo
     name: mongodb
     volumeMounts:
     - name: mongodb-data
       mountPath: /data/db
     ports:
     - containerPort: 27017
       protocol: TCP
   volumes:
   - name: mongodb-data
     persistentVolumeClaim:
       claimName: mongodb-pvc
```
### Then, create the pod:
 ```kubectl apply -f mongodb-pod.yaml```

### Verify the pod was created:
 ```kubectl get pods```

## Access the node and view the data within the volume.

### Connect to the node:

```ssh <node_hostname>```

### Switch to the /mnt/data directory:
```cd /mnt/data```

### List the contents of the directory:
```ls```

## Delete the pod and create a new pod with the same YAML spec

### Delete the pod:
```kubectl delete pod mongodb```

### Create a new pod:
```kubectl apply -f mongodb-pod.yaml```

## Verify the data still resides on the volume.

### Log in to the node:
```ssh <node_hostname>```

### Switch to the /mnt/data directory:
```cd /mnt/data```

### List the contents of the directory:
```ls ```