#!/bin/zsh

case=$1

export KUBECONFIG=~/.kube/karmada.config:~/.kube/members.config

alias ka='kubectl --context karmada-apiserver'
alias kh='kubectl --context karmada-host'
alias km1='kubectl --context member1'
alias km2='kubectl --context member2'
alias km3='kubectl --context member3'
alias km4='kubectl --context member4'

pp=pp
if [ "$(grep "PropagationPolicy" pp1.yaml)" = "kind: ClusterPropagationPolicy" ]; then pp=cpp; fi

function check_status(){
  sleep 3
  ka get rb nginx-deployment -o jsonpath='{.spec.clusters}' >> out.log
  echo -e '\n' >> out.log
  ka get deploy nginx --show-labels -o wide >> out.log
  echo -e '\n' >> out.log
  km1 get po -o wide >> out.log
  km2 get po -o wide >> out.log
  echo -e '\n' >> out.log
}

echo "" > out.log

# 1. 先创建 nginx，再创建 pp1，nginx 遵循 pp1 分发
if [[ $case == '' || $case == '1' ]]; then
  echo -e "---------case 1 (expect 1)----------\n" >> out.log

  ka apply -f nginx.yaml
  sleep 1
  ka apply -f pp1.yaml

  check_status

  ka delete -f nginx.yaml
  ka delete -f pp1.yaml
fi

# 2. 先创建 pp1，再创建 nginx，nginx 遵循 pp1 分发；再修改 pp1 的 placement (依然匹配 nginx)，nginx 不变；再修改 nginx，nginx 遵循修改后的 pp1 分发
if [[ $case == '' || $case == '2' ]]; then
  echo -e "---------case 2 (expect 1、1、2)----------\n" >> out.log

  ka apply -f pp1.yaml
  sleep 1
  ka apply -f nginx.yaml

  check_status

  ka patch ${pp} nginx-pp --type='json' -p '[{"op": "replace", "path": "/spec/placement/clusterAffinity/clusterNames", "value": ["member2"]}]'

  check_status

  ka label deploy nginx aa=bb

  check_status

  ka delete -f nginx.yaml
  ka delete -f pp1.yaml
fi

# 3. 先创建 pp1，再创建 nginx，nginx 遵循 pp1 分发；再创建一个抢占的优先级更高的 pp2，nginx 不变 (不可抢占)；再修改 nginx，nginx 遵循 pp2 分发
if [[ $case == '' || $case == '3' ]]; then
  echo -e "---------case 3 (expect 1、1、2)----------\n" >> out.log

  ka apply -f pp1.yaml
  sleep 1
  ka apply -f nginx.yaml

  check_status

  ka apply -f pp2.yaml

  check_status

  ka label deploy nginx aa=bb

  check_status

  ka delete -f nginx.yaml
  ka delete -f pp1.yaml
  ka delete -f pp2.yaml
fi

# 4. 先创建 pp1，再创建 nginx，nginx 遵循 pp1 分发；再修改 pp1 (依然匹配 nginx)，nginx 不变；再创建一个抢占的优先级更高的 pp2，nginx 不变；再修改 nginx，nginx 遵循 pp2 分发
if [[ $case == '' || $case == '4' ]]; then
  echo -e "---------case 4 (expect 1、1、1、2)----------\n" >> out.log

  ka apply -f pp1.yaml
  sleep 1
  ka apply -f nginx.yaml

  check_status

  ka patch ${pp} nginx-pp --type='json' -p '[{"op": "replace", "path": "/spec/placement/clusterAffinity/clusterNames", "value": ["member3"]}]'

  check_status

  ka apply -f pp2.yaml

  check_status

  ka label deploy nginx aa=bb

  check_status

  ka delete -f nginx.yaml
  ka delete -f pp1.yaml
  ka delete -f pp2.yaml
fi

# 5. 先创建 pp1、pp2 (pp1 < pp2)，再创建 nginx，nginx 遵循 pp2 分发；再修改 pp2 (不再匹配 nginx)，nginx 不变；再修改 nginx，nginx 循序 pp1 分发
if [[ $case == '' || $case == '5' ]]; then
  echo -e "---------case 5 (expect 2、2、1)----------\n" >> out.log

  ka apply -f pp1.yaml
  sleep 1
  ka apply -f pp2.yaml
  sleep 1
  ka apply -f nginx.yaml

  check_status

  ka patch ${pp} nginx-pp2 --type='json' -p '[{"op": "replace", "path": "/spec/resourceSelectors/0/name", "value": "nginx2"}]'

  check_status

  ka label deploy nginx aa=bb

  check_status

  ka delete -f nginx.yaml
  ka delete -f pp1.yaml
  ka delete -f pp2.yaml
fi

# 6. 先创建 pp1，再创建 nginx (2个副本)，nginx 遵循 pp1 分发；再删除 pp1，nginx 不变；
# 再修改 nginx (改为 5 个副本)，nginx 已有的 2 个副本不变；新增的 3 个副本处于 pending 状态；
# 再创建 pp2，nginx 所有 5 个副本遵循 pp2 分发 (未来尽可能保持原 2 个副本的惰性)
if [[ $case == '' || $case == '6' ]]; then
  echo -e "---------case 6 (expect 1、1、1、2)----------\n" >> out.log

  ka apply -f pp1.yaml
  sleep 1
  ka apply -f nginx.yaml

  check_status

  ka delete -f pp1.yaml

  check_status

  sleep 5
  ka patch deploy nginx --type='json' -p '[{"op": "replace", "path": "/spec/replicas", "value": 5}]'

  check_status

  ka apply -f pp2.yaml

  check_status

  ka delete -f nginx.yaml
  ka delete -f pp2.yaml
fi