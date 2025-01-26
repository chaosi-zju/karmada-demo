#!/bin/bash

# prepare cluster
rm ~/.kube/karmada-karmadactl-host.config ~/.kube/member4.config
kind delete clusters karmada-karmadactl-host member4
hack/create-cluster.sh karmada-karmadactl-host ~/.kube/karmada-karmadactl-host.config
sed -i 's/karmada-karmadactl-host/karmada-host/g' ~/.kube/karmada-karmadactl-host.config

# load images
export KUBECONFIG=~/.kube/karmada-karmadactl-host.config
CLUSTER=karmada-karmadactl-host hack/pullimg.sh

# build karmadactl
export VERSION=latest
make karmadactl
export PATH=/root/home/gopath/src/github.com/chaosi-zju/karmada/_output/bin/linux/amd64:${PATH}

# pack crd
cd  ./charts/karmada/
cp -r _crds crds
tar -zcvf ../../crds.tar.gz crds
cd -

karmadactl init \
    --karmada-controller-manager-image="docker.io/karmada/karmada-controller-manager:${VERSION}" \
    --karmada-scheduler-image="docker.io/karmada/karmada-scheduler:${VERSION}" \
    --karmada-webhook-image="docker.io/karmada/karmada-webhook:${VERSION}" \
    --karmada-aggregated-apiserver-image="docker.io/karmada/karmada-aggregated-apiserver:${VERSION}" \
    --crds=./crds.tar.gz

hack/create-cluster.sh member4 ~/.kube/member4.config
karmadactl join member4 --kubeconfig /etc/karmada/karmada-apiserver.config --karmada-context karmada-apiserver --cluster-kubeconfig ~/.kube/member4.config --cluster-context member4

karmadactl addons enable karmada-search karmada-descheduler karmada-metrics-adapter \
    --karmada-search-image="docker.io/karmada/karmada-search:${VERSION}" \
    --karmada-descheduler-image="docker.io/karmada/karmada-descheduler:${VERSION}" \
    --karmada-metrics-adapter-image="docker.io/karmada/karmada-metrics-adapter:${VERSION}"

karmadactl addons enable karmada-scheduler-estimator -C member4 \
    --karmada-scheduler-estimator-image="docker.io/karmada/karmada-scheduler-estimator:${VERSION}" \
    --member-kubeconfig ~/.kube/member4.config \
    --member-context member4

# uninstall
karmadactl addons disable karmada-search karmada-descheduler karmada-metrics-adapter
