#!/bin/bash

# 卸载
kubectl --context karmada-apiserver delete -f mcs-tmp.yaml
kubectl --context karmada-apiserver delete -f spark-app.yaml
kubectl --context karmada-apiserver delete -f ./MutatingWebhook.yaml
kubectl  --context karmada-apiserver delete -f ./ValidatingWebhook.yaml

helm uninstall spark-operator --namespace karmada-system
kubectl --context karmada-host delete secret spark-opaque-secret -n karmada-system
kubectl --context karmada-apiserver delete secret spark-opaque-secret
kubectl --context karmada-apiserver delete -f karmada.yaml
