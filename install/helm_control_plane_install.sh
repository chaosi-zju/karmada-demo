#!/bin/bash

rm ~/.kube/karmada-helm-host.config
hack/create-cluster.sh karmada-helm-host ~/.kube/karmada-helm-host.config
sed -i 's/karmada-helm-host/karmada-host/g' ~/.kube/karmada-helm-host.config

export KUBECONFIG=~/.kube/karmada-helm-host.config
CLUSTER=karmada-helm-host hack/pullimg.sh

kubectl delete ns karmada-system --force --grace-period=0; kubectl create ns karmada-system
helm install karmada charts/karmada --namespace karmada-system --set apiServer.hostNetwork=true,components={"metricsAdapter,search,descheduler"} --wait --timeout 800s

# ct install karmada --namespace "karmada-system" --debug --helm-extra-args "--timeout 800s" --skip-clean-up --target-branch "helm-0627"


ct install karmada --namespace "karmada-system" --helm-extra-args "--timeout 800s" --helm-extra-set-args "--set=apiServer.hostNetwork=true,components={'metricsAdapter,search,descheduler'}"

id=""
kubectl get secret -n karmada-system karmada${id}-kubeconfig -o jsonpath={.data.kubeconfig} | base64 -d > ~/.kube/karmada-helm-apiserver.config
sed -i'' -e "s/karmada${id}/karmada/g" ~/.kube/karmada-helm-apiserver.config
#APISERVER_IP=$(kubectl get ep karmada${id}-apiserver -n karmada-system | tail -n 1 | awk '{print $2}' | awk -F ":" '{print $1}')
APISERVER_IP=$(kubectl get ep kubernetes | tail -n 1 | awk '{print $2}' | awk -F ":" '{print $1}')
sed -i'' -e "s/.*karmada-apiserver.karmada-system.svc.cluster.local/${APISERVER_IP}  karmada-apiserver.karmada-system.svc.cluster.local/g" /etc/hosts
resolvectl flush-caches

helm uninstall karmada${id} -n karmada-system --debug
