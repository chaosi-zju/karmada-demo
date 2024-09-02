#!/bin/bash

hack/create-cluster.sh karmada-helm-host ~/.kube/karmada-helm-host.config
export KUBECONFIG=~/.kube/karmada-helm-host.config
sed -i 's/karmada-helm-host/karmada-host/g' ~/.kube/karmada-helm-host.config
CLUSTER=karmada-helm-host hack/pullimg.sh

kubectl delete ns karmada-system --force --grace-period=0; kubectl create ns karmada-system
ct install -n "karmada-system" --debug --helm-extra-args "--timeout 800s" --skip-clean-up --target-branch "helm-0627"

id="-l8rd5td9j6"
kubectl get secret -n karmada-system karmada${id}-kubeconfig -o jsonpath={.data.kubeconfig} | base64 -d > ~/.kube/karmada-helm-apiserver.config
sed -i'' -e "s/karmada${id}/karmada/g" ~/.kube/karmada-helm-apiserver.config
APISERVER_IP=$(kubectl get ep karmada${id}-apiserver -n karmada-system | tail -n 1 | awk '{print $2}' | awk -F ":" '{print $1}')
sed -i'' -e "s/.*karmada-apiserver.karmada-system.svc.cluster.local/${APISERVER_IP}  karmada-apiserver.karmada-system.svc.cluster.local/g" /etc/hosts
resolvectl flush-caches

helm uninstall karmada${id} -n karmada-system --debug
