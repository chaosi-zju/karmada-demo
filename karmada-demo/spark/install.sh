#!/bin/bash

# 安装
kubectl --context karmada-apiserver apply -f karmada.yaml
kubectl --context karmada-apiserver get secret spark-sa-secret -n karmada-system -o yaml | sed "s/kubernetes.io\/service-account-token/Opaque/g" | sed "s/spark-sa-secret/spark-opaque-secret/g" | sed -e "/resourceVersion/d;/uid/d" | kubectl --context karmada-host apply -f -
kubectl --context karmada-apiserver get secret spark-sa-secret -n karmada-system -o yaml | sed "s/kubernetes.io\/service-account-token/Opaque/g" | sed "s/spark-sa-secret/spark-opaque-secret/g" | sed -e "/resourceVersion/d;/uid/d" | sed "s/karmada-system/default/g" | kubectl --context karmada-apiserver apply -f -
kubectl --context karmada-apiserver apply -f ./spark-operator/crds --server-side=true

helm install spark-operator ./spark-operator/ --namespace karmada-system --create-namespace
kubectl --context karmada-host rollout status deployment spark-operator-controller -n karmada-system
kubectl --context karmada-host rollout status deployment spark-operator-webhook -n karmada-system

kubectl --context karmada-host get MutatingWebhookConfiguration spark-operator-webhook -o yaml > ./MutatingWebhook.yaml
kubectl --context karmada-host get ValidatingWebhookConfiguration spark-operator-webhook -o yaml > ./ValidatingWebhook.yaml
kubectl --context karmada-apiserver apply -f ./MutatingWebhook.yaml
kubectl --context karmada-apiserver apply -f ./ValidatingWebhook.yaml

kubectl --context karmada-apiserver apply -f spark-app.yaml

while [[ $(kubectl --context karmada-apiserver get svc | grep -c "driver-svc") -eq 0 ]]; do echo "wait driver svc.."; sleep 1; done
name=$(kubectl --context karmada-apiserver get svc | grep "driver-svc" | awk '{print $1}')
sed -e "s/spark-test-driver-svc/${name}/g" mcs.yaml > mcs-tmp.yaml
kubectl --context karmada-apiserver apply -f mcs-tmp.yaml

#docker pull docker.io/kubeflow/spark-operator:2.0.2
#kind load docker-image docker.io/kubeflow/spark-operator:2.0.2 --name karmada-host
#
#docker pull apache/spark:v3.1.3
#kind load docker-image ghcr.io/apache/spark-docker/spark:3.5.2 --name karmada-host
#kind load docker-image ghcr.io/apache/spark-docker/spark:3.5.2 --name member1
#
#
#ka apply -f cpp.yaml
#ka apply -f ./spark-operator/crds --server-side=true
#
#helm install spark-operator ./spark-operator/ \
#    --namespace karmada-system \
#    --create-namespace
#
#
#helm install spark-operator spark-operator/spark-operator \
#    --namespace karmada-system \
#    --create-namespace
#
#helm uninstall spark-operator --namespace karmada-system
