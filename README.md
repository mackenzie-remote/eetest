### Minikube Proof of Concept

This repository contains two methods of getting a simple Hello World python Docker container running on a local [Minikube](https://kubernetes.io/docs/setup/minikube/) instance.

Provided is a scripted set-up, to get you going quickly, and a [Walkthrough](WALKTHROUGH.md) guide for those that wish to run the commands themselves.

## Dependencies

Both methods require that you first have the following software installed:

* [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
* [Docker](https://docker.com)
* [Kubernetes CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Scripted Deployment

Once you have installed the necessary dependencies, and have cloned this git repository, simply launch the `deploy.sh` script.

```
$ ./deploy.sh
```

This will:

* Check the dependencies are present
* Start Minikube
* Build the `helloworld` Python docker image
* Create a *Deployment* and *Service* on the Minikube instance
* Create a port forward rule and give you the URL to access the `helloworld` container locally.

The script is idepotent and can run multiple times. If you encounter any issues the script will terminate and allow you to re-run it after the issue has been resolved.
