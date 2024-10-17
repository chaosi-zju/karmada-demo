#!/bin/bash

docker pull docker.io/kubeflow/spark-operator:2.0.2
kind load docker-image docker.io/kubeflow/spark-operator:2.0.2 --name karmada-host

docker pull apache/spark:v3.1.3
kind load docker-image apache/spark:v3.1.3 --name karmada-host
kind load docker-image apache/spark:v3.1.3 --name member1

helm repo add spark-operator https://kubeflow.github.io/spark-operator
helm repo update
helm install spark-operator spark-operator/spark-operator \
    --namespace karmada-system \
    --create-namespace

helm uninstall spark-operator --namespace karmada-system
