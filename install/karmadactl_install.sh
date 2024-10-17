#!/bin/bash

rm ~/.kube/karmada-karmadactl-host.config ~/.kube/member4.config
kind delete clusters karmada-karmadactl-host member4
hack/create-cluster.sh karmada-karmadactl-host ~/.kube/karmada-karmadactl-host.config
sed -i 's/karmada-karmadactl-host/karmada-host/g' ~/.kube/karmada-karmadactl-host.config

export KUBECONFIG=~/.kube/karmada-karmadactl-host.config
CLUSTER=karmada-karmadactl-host hack/pullimg.sh

# install
export LDFLAGS="-X github.com/karmada-io/karmada/pkg/version.gitVersion=v1.11.0"
make karmadactl
export PATH=/root/home/gopath/src/github.com/chaosi-zju/karmada/_output/bin/linux/amd64/:${PATH}

karmadactl init

hack/create-cluster.sh member4 ~/.kube/member4.config
karmadactl join member4 --kubeconfig /etc/karmada/karmada-apiserver.config --karmada-context karmada-apiserver --cluster-kubeconfig ~/.kube/member4.config --cluster-context member4

karmadactl addons enable karmada-search karmada-descheduler karmada-metrics-adapter
karmadactl addons enable karmada-scheduler-estimator -C member4 --member-kubeconfig ~/.kube/member4.config --member-context member4
