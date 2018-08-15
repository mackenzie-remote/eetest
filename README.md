### Minikube Proof of Concept

## Introduction

This repository contains a simple guide to getting started with [Minikube](https://kubernetes.io/docs/setup/minikube/), which is an easy way to test out [Kubernetes](https://kubernetes.io) on your local machine.

## Minikube Set-up

### Install Minikube

Due to time constaints, this guide assumes you are running MacOS and are already familiar with the command-line.

You will need root if you do not already have the prerequisite software installed on your machine.

0. Follow the instructions to [Install Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) on your local machine.

1. Verify you have `minikube` and `kubectl` installed and accessible in your path. (NB: Your versions may vary slightly).

```
$ minikube version
minikube version: v0.28.2
$ kubectl version --client --short
Client Version: v1.10.2
```

2. Start the local minikube cluster:
```
$ minikube start
```
3. Go and make a Hot Beverage Of Your Choice. (Minikube may take some time to start depending on your internet speed and local compute).

4. Run a `kubectl get nodes` command, if you get output similar to the below, then your cluster is up and running.
```
$ kubectl get nodes
NAME       STATUS    ROLES     AGE       VERSION
minikube   Ready     master    20s       v1.10.0
```

### Creating Our First Application in Kubernetes

Before we start, we need a docker image. We could create our own `Dockerfile`, build our own image, create an account on a public docker image repository (for example, [Docker Hub](https://hub.docker.com/)) and upload this image.

In this instance though, we will simply use a Python Hello World image that is available for us to use.

### kubectl run vs kubectl apply -f

Again, for the simple reason of speed, we will use `kubectl run` to launch our container. For an application that is being created correctly, we should not really do this except for quick tests, and should instead write `yaml` files that we can commit to source control.

### Hello-World

Let's run a copy of the `hello-world` application.

```
$ kubectl run --image=drhelius/helloworld-python-microservice hello-world --port=8080
```

Check it is in state `Running`:
```
$ kubectl get pod -o wide
NAME                          READY     STATUS    RESTARTS   AGE       IP           NODE
hello-world-ccccc7848-gqj6d   1/1       Running   0          28s       172.17.0.4   minikube
```

To hit the application, the simplest way is to use the `kubectl port-forward` command to bypass any potential issues around networking on your local machine.

```
kubectl port-forward deployment/hello-world 8080
```

You should now be able to hit the Hello World application on port http://localhost:8080 - so in another terminal window:

```
$ curl http://localhost:8080
Hello World from host "hello-world-ccccc7848-gqj6d".
```

### Scaling up Hello-World

We only have one copy of the pod running. We can scale this up or down using kubectl commands.

First, check we only have 1 replia of each.

```
$ kubectl get deployment
NAME          DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
hello-world   1         1         1            1           4m
```

Then let's scale it up to 3. We also can run the above `get deployment` command straight after with the `-w` option, which watches the deployment, so we can see it scaling up in real time (Kubernetes isn't very visual so we have to take what we can get!)

```
$ kubectl scale deployment hello-world --replicas=3; kubectl get deployment hello-world -w
deployment.extensions "hello-world" scaled
NAME          DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
hello-world   3         3         3            1           6m
hello-world   3         3         3         2         6m
hello-world   3         3         3         3         6m
```

### Services and Load Balancers

We currently have no way to access the service internally, but we can easily create a service on the command line with the `kubectl expose` command:

```
kubectl expose deployment hello-world
```

We can now see the service that has been created:

```
$ kubectl get svc
NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
hello-world   ClusterIP   10.101.241.178   <none>        8080/TCP   2s
kubernetes    ClusterIP   10.96.0.1        <none>        443/TCP    24m
```

Exposing a Kubernetes deployment to the outside world is out of scope of this PoC. There are many way to achieve this, such as setting up a [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) controller. If we were running on a cloud provider such as AWS or GCP we could potentially use a service with a `LoadBalancer`, which would be created on the fly by the compute instance. Or we could use a `NodePort` option on the service, and create our Cloud Load Balancer ourselves and point it at the specified port and auto scaling group containing the Kubernetes Nodes.
