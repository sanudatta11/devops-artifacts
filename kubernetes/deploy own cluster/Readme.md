# Kubernetes Bare Installation and Sample Deployment

## Get the Docker gpg, and add it to your repository.

Run the following commands to get the Docker gpg key and add it to your repository:

`curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`

`sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"`

## Get the Kubernetes gpg key, and add it to your repository.
--------------------------------------------
Run the following commands to get the Kubernetes gpg key and add it to your repository:

`curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -`

`cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list`
`deb https://apt.kubernetes.io/ kubernetes-xenial main`
`sudo apt-get update`

## Install Docker, kubelet, kubeadm, and kubectl.

Run the following command to install Docker, kubelet, kubeadm, and kubectl:

`sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu kubelet=1.13.5-00 kubeadm=1.13.5-00 kubectl=1.13.5-00`

## Initialize the Kubernetes cluster.

Run the following command to initialize the cluster using kubeadm:

`sudo kubeadm init --pod-network-cidr=10.244.0.0/16`

## Set up local kubeconfig.
--------------------------------------------
Run the following command to set up local kubeconfig:

`mkdir -p $HOME/.kube`
`sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config`
`sudo chown $(id -u):$(id -g) $HOME/.kube/config`

## Apply the flannel CNI plugin as a network overlay.
--------------------------------------------
Run the following command to apply flannel:

`kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml`

## Join the worker nodes to the cluster, and verify they have joined successfully.
--------------------------------------------
Run the following command to join the worker nodes to the cluster:

`sudo kubeadm join <your unique string from the output of kubeadm init>`

## Run a deployment that includes at least one pod, and verify it was successful.
--------------------------------------------
Run the following commands to run a deployment of ngnix and verify:

`kubectl run nginx --image=nginx`

`kubectl get deployments`

## Verify the pod is running and available.
--------------------------------------------
Run the following command to verify the pod is up and running:

`kubectl get pods`


## Use port forwarding to extend port 80 to 8081, and verify access to the pod directly.
--------------------------------------------
Run the following command to forward the container port 80 to 8081:

`kubectl port-forward [pod_name] 8081:80`

Open a new shell to the Kubernetes master and run the following command:

`curl --head http://127.0.0.1:8081`

> NOTE: You must leave the previous session open in order to properly port forward. As soon as you close that session, the port will NO LONGER be open.


## Execute a command directly on a pod.
--------------------------------------------
Run this command to execute the nginx version command from a pod:

`kubectl exec -it <pod_name> -- nginx -v`


## Create a service, and verify connectivity on the node port.
--------------------------------------------
Run these commands to create a NodePort service and verify the connectivity on a worker node:

`kubectl expose deployment nginx --port 80 --type NodePort`
`kubectl get services`
`curl -I localhost:$node_port`