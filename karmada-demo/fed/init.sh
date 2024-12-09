#!/usr/bin/env bash

export KUBECONFIG=~/.kube/karmada.config:~/.kube/members.config

# 将member1集群的maxPods改为10(系统组件还需占用10)
maxPodsMem1=$(docker exec -it member1-control-plane cat /var/lib/kubelet/config.yaml | grep maxPods)
if [ "$maxPodsMem1" = "" ]; then
  docker exec -it member1-control-plane bash -c 'echo "maxPods: 20" >> /var/lib/kubelet/config.yaml'
else
  docker exec -it member1-control-plane bash -c 'sed -ie "s/maxPods:.*/maxPods: 20/g" /var/lib/kubelet/config.yaml'
fi
docker exec -it member1-control-plane bash -c 'systemctl restart kubelet.service'

# 将member2集群的maxPods改为10(系统组件还需占用10)
maxPodsMem2=$(docker exec -it member2-control-plane cat /var/lib/kubelet/config.yaml | grep maxPods)
if [ "$maxPodsMem2" = "" ]; then
  docker exec -it member2-control-plane bash -c 'echo "maxPods: 20" >> /var/lib/kubelet/config.yaml'
else
  docker exec -it member2-control-plane bash -c 'sed -ie "s/maxPods:.*/maxPods: 20/g" /var/lib/kubelet/config.yaml'
fi
docker exec -it member2-control-plane bash -c 'systemctl restart kubelet.service'


# 创建deployment、policy、fedhpa
kubectl --context karmada-apiserver apply -f nginx.yaml
kubectl --context karmada-apiserver apply -f policy.yaml
kubectl --context karmada-apiserver apply -f fedhpa.yaml


# 查看deployment在成员集群分布
karmadactl --karmada-context karmada-apiserver get deploy --operation-scope=members


# 对member1集群压测(-n 总请求数; -c 并发数; -q 每个并发队列的QPS)，需要先安装hey: https://github.com/rakyll/hey
#member1=$(kubectl --context member1 get node member1-control-plane -o jsonpath='{.status.addresses[0].address}')
#hey -n 60000000 -c 10 -q 10 http://${member1}:30080
#hey -n 60000000 -c 100 -q 100 http://${member1}:30080
