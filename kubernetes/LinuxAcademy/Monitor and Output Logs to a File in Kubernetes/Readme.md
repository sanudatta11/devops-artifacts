# Monitor and Output Logs to a File in Kubernetes

## Additional Information and Resources

You have been given access to a three-node cluster. Within that cluster, you must discover the pod that isn’t running as it should. Then, you must collect the logs and save them to a file in order to capture the problematic messages from the log. Perform the following tasks in order to complete this hands-on lab:

## Identify the pod that is not running in the cluster.
Collect the logs from the pod and try to identify the problem.
Output the logs to a file in order to share that file with your colleagues.

## Identify the problematic pod in your cluster.

Use the following command to view all the pods in your cluster:

```kubectl get pods --all-namespaces```

##Collect the logs from the pod.

Use the following command to collect the logs from the pod:

```kubectl logs <pod_name> -n <namespace_name>```

## Output the logs to a file.

Use the following command to output the logs to a file:

```kubectl logs <pod_name> -n <namespace_name> > broken-pod.log```