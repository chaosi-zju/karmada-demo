#!/bin/bash

# 准备集群
rm ~/.kube/karmada-operator-host.config ~/.kube/karmada-operator-apiserver.config ~/.kube/member5.config
kind delete clusters karmada-operator-host member5
hack/create-cluster.sh karmada-operator-host ~/.kube/karmada-operator-host.config
sed -i 's/karmada-operator-host/karmada-host/g' ~/.kube/karmada-operator-host.config
export KUBECONFIG=~/.kube/karmada-operator-host.config
CLUSTER=karmada-operator-host hack/pullimg.sh

# 准备operator镜像
export VERSION="latest"
export REGISTRY="docker.io/karmada"
export LDFLAGS="-X github.com/karmada-io/karmada/pkg/version.gitVersion=v1.12.0"
sed -i'' -e "s/RUN apk /#RUN apk /g" cluster/images/Dockerfile
make image-karmada-operator GOOS="linux" --directory=.
kind load docker-image docker.io/karmada/karmada-operator:latest --name karmada-operator-host

# 安装operator
helm upgrade -i karmada-operator -n karmada-system --create-namespace --dependency-update ./charts/karmada-operator --debug

# 安装Karmada
kubectl apply -f operator/config/crds/

sed -i'' -e "s/karmada-demo/karmada/g" operator/config/samples/karmada.yaml
#sed -i'' -e "s/namespace: test/namespace: karmada-system/g" operator/config/samples/karmada.yaml
sed -i'' -e "s/imageTag: v1.11.1/imageTag: latest/g" operator/config/samples/karmada.yaml
sed -i'' -e "s/replicas: 2/replicas: 1/g" operator/config/samples/karmada.yaml
sed -i'' -e "s/    # /    /g" operator/config/samples/karmada.yaml
kubectl apply -f operator/config/samples/karmada.yaml

kubectl get secret -n karmada-system karmada-admin-config -o jsonpath={.data.kubeconfig} | base64 -d > ~/.kube/karmada-operator-apiserver.config
sed -i'' -e "s/karmada-admin@karmada-apiserver/karmada-apiserver/g" ~/.kube/karmada-operator-apiserver.config

# 添加成员集群
hack/create-cluster.sh member5 ~/.kube/member5.config
karmadactl join member5 --kubeconfig ~/.kube/karmada-operator-apiserver.config --karmada-context karmada-apiserver --cluster-kubeconfig ~/.kube/member5.config --cluster-context member5
karmadactl addons enable karmada-scheduler-estimator -C member5 --member-kubeconfig ~/.kube/member5.config --member-context member5

# 卸载
karmadactl unjoin member5 --kubeconfig ~/.kube/karmada-operator-apiserver.config --karmada-context karmada-apiserver --cluster-kubeconfig ~/.kube/member5.config --cluster-context member5
kubectl delete -f operator/config/samples/karmada.yaml

sed -i'' -e "s/serviceType: .*/serviceType: LoadBalancer/g" operator/config/samples/karmada.yaml
sed -i'' -e "s/serviceType: .*/serviceType: NodePort/g" operator/config/samples/karmada.yaml
sed -i'' -e "s/serviceType: .*/serviceType: ClusterIP/g" operator/config/samples/karmada.yaml
