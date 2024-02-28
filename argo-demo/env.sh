#!/bin/bash

kind create cluster --name karmada-host --kubeconfig ~/.kube/config --image kindest/node:v1.27.3

kind load docker-image quay.io/argoproj/argocli:v3.5.0-rc2 --name karmada-host

kind load docker-image quay.io/argoproj/workflow-controller:v3.5.0-rc2 --name karmada-host

kind load docker-image quay.io/argoproj/argoexec:v3.5.0-rc2 --name karmada-host

kubectl create ns argo

kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.5.0-rc2/install.yaml

kubectl patch deploy argo-server -n argo --type='json' -p '[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": ["server", "--auth-mode=server"]}]'

kubectl patch svc argo-server -n argo --type='json' -p '[
{"op": "replace", "path": "/spec/type", "value": "NodePort"},
{"op": "add", "path": "/spec/ports/0/nodePort", "value": 30000}]'

kubectl get svc argo-server -n argo

# argo server --kubeconfig ~/.kube/karmada.config --context karmada-apiserver --auth-mode server -n argo
# argo --kubeconfig ~/.kube/karmada.config --context karmada-apiserver list
# argo --kubeconfig ~/.kube/karmada.config --context karmada-apiserver submit dag-diamond.yaml

