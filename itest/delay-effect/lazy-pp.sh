#!/bin/zsh

case=$1

export KUBECONFIG=~/.kube/karmada.config:~/.kube/members.config

alias ka='kubectl --context karmada-apiserver'
alias kh='kubectl --context karmada-host'
alias km1='kubectl --context member1'
alias km2='kubectl --context member2'
alias km3='kubectl --context member3'
alias km4='kubectl --context member4'

function check_status(){
  sleep 3
  ka get deploy nginx --show-labels -o wide >> out.log 2>&1
  echo -e '\n' >> out.log

  ka get rb nginx-deployment -o jsonpath='{.spec.clusters}' >> out.log 2>&1
  echo -e '\n' >> out.log

  km1 get po -o wide >> out.log 2>&1
  echo -e '\n' >> out.log
  km2 get po -o wide >> out.log 2>&1
  echo -e '\n' >> out.log
}

function assert() {
  resource=$1
  name=$2
  resourceExistInMember1=$3
  resourceExistInMember2=$4

  if [[ "${resourceExistInMember1}" == "true" && "$(km1 get "${resource}" "${name}" 2>&1 | wc -l)" == "1" ]]; then
    echo -e 'Failed.\n' >> out.log
    exit 1
  elif [[ "${resourceExistInMember1}" == "false" && "$(km1 get "${resource}" "${name}" 2>&1 | wc -l)" = "2" ]]; then
    echo -e 'Failed.\n' >> out.log
    exit 1
  fi

  if [[ "${resourceExistInMember2}" == "true" && "$(km2 get "${resource}" "${name}" 2>&1 | wc -l)" == "1" ]]; then
    echo -e 'Failed.\n' >> out.log
    exit 1
  elif [[ "${resourceExistInMember2}" == "false" && "$(km2 get "${resource}" "${name}" 2>&1 | wc -l)" == "2" ]]; then
    echo -e 'Failed.\n' >> out.log
    exit 1
  fi

  echo -e 'Success.\n' >> out.log
  echo -e 'Success.'
}

echo "" > out.log

if [[ $case == '' || $case == '11' ]]; then
  echo -e "---------1.1 先创建延时生效的policy，再创建工作负载，立即分发生效----------\n\n" >> out.log

  ka apply -f pp-delay.yaml
  sleep 1
  ka apply -f nginx.yaml
  check_status
  assert deploy nginx true false

  ka delete -f pp-delay.yaml
  ka delete -f nginx.yaml
fi

if [[ $case == '' || $case == '12' ]]; then
  echo -e "---------1.2 先创建工作负载，再创建立即生效的policy，创建后工作负载立即分发生效----------\n\n" >> out.log

  ka apply -f nginx.yaml
  sleep 1
  ka apply -f pp.yaml
  check_status
  assert deploy nginx false true

  ka delete -f pp.yaml
  ka delete -f nginx.yaml
fi

if [[ $case == '' || $case == '13' ]]; then
  echo -e "---------1.3 先创建工作负载，再创建延时生效的policy不会立即生效，待工作负载变更时生效----------\n\n" >> out.log

  ka apply -f nginx.yaml
  sleep 1
  ka apply -f pp-delay.yaml
  check_status
  assert deploy nginx false false

  echo -e "----------资源变更\n\n" >> out.log
  ka label deploy nginx --overwrite refresh-time=$(date +%s)
  check_status
  assert deploy nginx true false

  ka delete -f pp-delay.yaml
  ka delete -f nginx.yaml
fi

if [[ $case == '' || $case == '21' ]]; then
  echo -e "---------2.1 全局配置为立即生效，cpp配置也为立即生效，修改cpp后配置立即生效----------\n\n" >> out.log

  ka apply -f cpp.yaml
  sleep 1
  ka apply -f nginx.yaml
  check_status
  assert deploy nginx true false

  echo -e "----------修改cpp配置，立即生效\n\n" >> out.log
  ka patch cpp cpp --type='json' -p '[{"op": "replace", "path": "/spec/placement/clusterAffinity/clusterNames", "value": ["member2"]}]'
  check_status
  assert deploy nginx false true

  ka delete -f cpp.yaml
  ka delete -f nginx.yaml
fi

if [[ $case == '' || $case == '22' ]]; then
  echo -e "---------2.2 全局配置为立即生效，cpp配置为延时生效，修改cpp后，在修改deploy/service配置时分别生效----------\n\n" >> out.log

  ka apply -f cpp-delay.yaml
  sleep 1
  ka apply -f nginx.yaml
  check_status
  assert deploy nginx true false

  echo -e "----------修改cpp-delay配置(不变)\n\n" >> out.log
  ka patch cpp cpp-delay --type='json' -p '[{"op": "replace", "path": "/spec/placement/clusterAffinity/clusterNames", "value": ["member2"]}]'
  check_status
  assert deploy nginx true false

  echo -e "----------资源变更(生效)\n\n" >> out.log
  ka label deploy nginx --overwrite refresh-time=$(date +%s)
  check_status
  assert deploy nginx false true

  ka delete -f cpp-delay.yaml
  ka delete -f nginx.yaml
fi

if [[ $case == '' || $case == '23' ]]; then
  echo -e "---------2.3 修改pp中的生效模式，由延时生效改为立即生效成功----------\n\n" >> out.log

  ka apply -f pp-delay.yaml
  sleep 1
  ka apply -f nginx.yaml
  check_status
  assert deploy nginx true false

  echo -e "----------修改pp，延时->立即(生效)\n\n" >> out.log
  ka patch pp pp-delay --type='json' -p '[{"op": "remove", "path": "/spec/activationPreference"}, {"op": "replace", "path": "/spec/placement/clusterAffinity/clusterNames", "value": ["member2"]}]'
  ka get pp pp-delay -o jsonpath='{.spec.activationPreference}{"\n"}{.spec.placement.clusterAffinity.clusterNames}{"\n\n"}' >> out.log
  check_status
  assert deploy nginx false true

  ka delete -f pp-delay.yaml
  ka delete -f nginx.yaml
fi

if [[ $case == '' || $case == '24' ]]; then
  echo -e "---------2.4 修改cpp中的生效模式，由立即生效改为延时生效----------\n\n" >> out.log

  ka apply -f cpp.yaml
  sleep 1
  ka apply -f nginx.yaml
  check_status
  assert deploy nginx true false

  echo -e "----------修改cpp，立即->延时(不变)\n\n" >> out.log
  ka patch cpp cpp --type='json' -p '[{"op": "replace", "path": "/spec/activationPreference", "value": "Lazy"}, {"op": "replace", "path": "/spec/placement/clusterAffinity/clusterNames", "value": ["member2"]}]'
  ka get pp pp-delay -o jsonpath='{.spec.activationPreference}{"\n"}{.spec.placement.clusterAffinity.clusterNames}{"\n\n"}' >> out.log
  check_status
  assert deploy nginx true false

  echo -e "----------资源变更(生效)\n\n" >> out.log
  ka label deploy nginx --overwrite refresh-time=$(date +%s)
  check_status
  assert deploy nginx false true

  ka delete -f cpp.yaml
  ka delete -f nginx.yaml
fi

if [[ $case == '' || $case == '25' ]]; then
  echo -e "---------2.5 删除policy中的生效模式配置，修改后该策略和全局配置一致----------\n\n" >> out.log

  ka apply -f pp-delay.yaml
  sleep 1
  ka apply -f nginx.yaml
  check_status
  assert deploy nginx true false

  echo -e "----------修改pp并删除activationPreference字段(立即生效)\n\n" >> out.log
  ka patch pp pp-delay --type='json' -p '[{"op": "remove", "path": "/spec/activationPreference"}, {"op": "replace", "path": "/spec/placement/clusterAffinity/clusterNames", "value": ["member2"]}]'
  ka get pp pp-delay -o jsonpath='{.spec.activationPreference}{"\n"}{.spec.placement.clusterAffinity.clusterNames}{"\n\n"}' >> out.log
  check_status
  assert deploy nginx false true

  ka delete -f pp-delay.yaml
  ka delete -f nginx.yaml
fi

if [[ $case == '' || $case == '31' ]]; then
  echo -e "---------3.1 延迟生效的pp，修改后资源无法匹配任何policy,分发实例保持现状 ----------\n\n" >> out.log

  ka apply -f pp-delay.yaml
  sleep 1
  ka apply -f nginx.yaml
  check_status
  assert deploy nginx true false

  echo -e "---------修改pp\n\n" >> out.log
  ka apply -f pp-delay-selector.yaml
  check_status
  assert deploy nginx true false

  ka delete -f pp-delay-selector.yaml
  ka delete -f nginx.yaml
fi

if [[ $case == '' || $case == '32' ]]; then
  echo -e "---------3.2 延迟生效的cpp删除后，资源无法匹配到任何policy，分发实例保持现状 ----------\n\n" >> out.log

  ka apply -f cpp-delay.yaml
  sleep 1
  ka apply -f nginx.yaml
  check_status
  assert deploy nginx true false

  echo -e "---------删除cpp\n\n" >> out.log
  ka delete -f cpp-delay.yaml
  check_status
  assert deploy nginx true false

  ka delete -f nginx.yaml
fi

if [[ $case == '' || $case == '33' ]]; then
  echo -e "---------3.3 立即生效的cpp,修改cpp后资源无法匹配任何policy,分发实例保持现状 ----------\n\n" >> out.log

  ka apply -f cpp.yaml
  sleep 1
  ka apply -f nginx.yaml
  check_status
  assert deploy nginx true false

  echo -e "----------修改cpp\n\n" >> out.log
  ka apply -f cpp-selector.yaml
  check_status
  assert deploy nginx true false

  ka delete -f cpp-selector.yaml
  ka delete -f nginx.yaml
fi

if [[ $case == '' || $case == '34' ]]; then
  echo -e "---------3.4 资源匹配pp1时，修改pp1后资源匹配到了立即生效的pp2，资源按照pp2的策略立即进行调整（member1变member2） ----------\n\n" >> out.log

  ka apply -f pp-delay.yaml
  sleep 1
  ka apply -f nginx.yaml
  check_status
  assert deploy nginx true false

  echo -e "----------修改pp-delay，匹配 pp\n\n" >> out.log
  ka apply -f pp.yaml
  sleep 1
  ka apply -f pp-delay-selector.yaml
  check_status
  assert deploy nginx false true

  ka delete -f pp-delay-selector.yaml
  ka delete -f nginx.yaml
  ka delete -f pp.yaml
fi

if [[ $case == '' || $case == '35' ]]; then
  echo -e "---------3.5 资源匹配pp1时，修改pp1后资源匹配到延时生效的pp2，在资源进行变更后匹配pp2进行调整（member1变member2） ----------\n\n" >> out.log

  ka apply -f pp-delay.yaml
  sleep 1
  ka apply -f nginx.yaml
  check_status
  assert deploy nginx true false

  echo -e "----------修改pp-delay,匹配pp-delay2（不变）\n\n" >> out.log
  ka apply -f pp-delay-2.yaml
  sleep 1
  ka apply -f pp-delay-selector.yaml
  check_status
  assert deploy nginx true false

  echo -e "----------资源变更\n\n" >> out.log
  ka label deploy nginx --overwrite refresh-time=$(date +%s)
  check_status
  assert deploy nginx false true

  ka delete -f pp-delay-selector.yaml
  ka delete -f pp-delay-2.yaml
  ka delete -f nginx.yaml
fi

if [[ $case == '' || $case == '36' ]]; then
  echo -e "---------3.6 资源匹配pp1时，创建pp2为立即生效，抢占模式，则资源立刻匹配pp2生效 ----------\n\n" >> out.log

  ka apply -f pp-delay.yaml
  sleep 1
  ka apply -f nginx.yaml
  check_status
  assert deploy nginx true false

  echo -e "----------创建立即生效，抢占模式的pp2\n\n" >> out.log
  ka apply -f pp-preem.yaml
  check_status
  assert deploy nginx false true

  ka delete -f pp-delay.yaml
  ka delete -f pp-preem.yaml
  ka delete -f nginx.yaml
fi

if [[ $case == '' || $case == '37' ]]; then
  echo -e "---------3.7 资源匹配pp1时，创建pp2为延时生效，抢占模式，则资源在变更时生效pp2的策略 ----------\n\n" >> out.log

  ka apply -f pp-delay.yaml
  sleep 1
  ka apply -f nginx.yaml
  check_status
  assert deploy nginx true false

  echo -e "----------创建延时生效，抢占模式的pp2(不变)\n\n" >> out.log
  ka apply -f pp-delay-preem.yaml
  check_status
  assert deploy nginx true false

  echo -e "----------资源变更(生效)\n\n" >> out.log
  ka label deploy nginx --overwrite refresh-time=$(date +%s)
  check_status
  assert deploy nginx false true

  ka delete -f pp-delay.yaml
  ka delete -f pp-delay-preem.yaml
  ka delete -f nginx.yaml
fi

if [[ $case == '' || $case == '41' ]]; then
  echo -e "---------4.1 先创deploy和cm，再创延迟生效且跟随分发的pp分发deploy,不变；再变更deploy,两者都分发；再更新pp的集群，不变；再变更 deploy，两者都分发----------\n\n" >> out.log

  ka apply -f nginx-dep.yaml
  sleep 1
  ka apply -f pp-delay-dep.yaml
  check_status
  assert deploy nginx false false
  assert cm nginx-config false false

  echo -e "----------变更deploy,两者都分发\n\n" >> out.log
  ka label deploy nginx --overwrite refresh-time=$(date +%s)
  check_status
  assert deploy nginx true false
  assert cm nginx-config true false

  echo -e "----------更新pp的集群，不变\n\n" >> out.log
  ka patch pp pp-delay-dep --type='json' -p '[{"op": "replace", "path": "/spec/placement/clusterAffinity/clusterNames", "value": ["member2"]}]'
  check_status
  assert deploy nginx true false
  assert cm nginx-config true false

  echo -e "----------变更deploy,两者都分发\n\n" >> out.log
  ka label deploy nginx --overwrite refresh-time=$(date +%s)
  check_status
  assert deploy nginx false true
  assert cm nginx-config false true

  ka delete -f pp-delay-dep.yaml
  ka delete -f nginx-dep.yaml
fi

if [[ $case == '' || $case == '42' ]]; then
  echo -e "---------4.2 先创deploy和cm，再创延迟生效的pp分发deploy和cm,不变；再变更deploy,只deploy分发,cm不分发；再在pp上开启跟随并改集群，不变；再变更deploy，两者都分发----------\n\n" >> out.log

  ka apply -f nginx-dep.yaml
  sleep 1
  ka apply -f pp-delay-multi.yaml
  check_status
  assert deploy nginx false false
  assert cm nginx-config false false

  echo -e "----------变更deploy,只deploy被分发,cm不分发\n\n" >> out.log
  ka label deploy nginx --overwrite refresh-time=$(date +%s)
  check_status
  assert deploy nginx true false
  assert cm nginx-config false false

  echo -e "----------在pp上开启跟随并改集群，不变\n\n" >> out.log
  ka patch pp pp-delay-multi --type='json' -p '[{"op": "add", "path": "/spec/propagateDeps", "value": true}, {"op": "replace", "path": "/spec/placement/clusterAffinity/clusterNames", "value": ["member2"]}]'
  ka get pp pp-delay-multi -o jsonpath='{.spec.propagateDeps}{"\n"}{.spec.placement.clusterAffinity.clusterNames}{"\n\n"}' >> out.log
  check_status
  assert deploy nginx true false
  assert cm nginx-config false false

  echo -e "----------变更deploy,都分发\n\n" >> out.log
  ka label deploy nginx --overwrite refresh-time=$(date +%s)
  check_status
  assert deploy nginx false true
  assert cm nginx-config false true

  ka delete -f pp-delay-multi.yaml
  ka delete -f nginx-dep.yaml
fi

#先创建延时生效的policy，再创建工作负载，立即分发生效
#先创建工作负载，再创建立即生效的policy，创建后工作负载立即分发生效
#先创建工作负载，再创建延时生效的policy不会立即生效，待工作负载变更时生效
#
#X 全局配置为延时生效，pp中不配置时，修改pp后，触发deploy重新部署时生效
#X 全局配置为延时生效，pp中配置为立即生效时，修改pp后立即生效
#全局配置为立即生效，cpp配置也为立即生效，修改cpp后配置立即生效
#全局配置为立即生效，cpp配置为延时生效，修改cpp后，在修改deploy/service配置时分别生效
#X 修改全局生效模式，由立即生效改为延时生效，修改后未配置生效策略的policy为延时生效模式
#X 修改全局生效模式，由延时生效改为立即生效，修改后未配置生效策略的policy为立即生效模式
#修改pp中的生效模式，由延时生效改为立即生效成功
#修改cpp中的生效模式，由立即生效改为延时生效
#删除policy中的生效模式配置，修改后该策略和全局配置一致
#X 延时生效模式，修改pp，federatedhpa触发弹性扩缩容时，修改后的pp生效
#X 延时生效模式，修改pp，cce hpa触发弹性扩缩容，修改后的pp生效
#X 延时生效模式，修改pp，cce cronhpa触发弹性扩缩容，修改后的pp生效
#
#延时生效的pp，修改pp后资源无法匹配任何policy，分发实例保持现状
#延时生效的cpp删除后，资源无法匹配到任何policy，分发实例保持现状
#立即生效的cpp，修改cpp后资源无法匹配任何policy，分发实例保持现状
#资源匹配pp1时，修改pp1后资源匹配到了立即生效的pp2，资源按照pp2的策略立即进行调整
#资源匹配pp1时，修改pp1后资源匹配到延时生效的pp2，在资源进行变更后匹配pp2进行调整
#资源匹配pp1时，创建pp2为立即生效、抢占模式，则资源立刻匹配pp2生效
#资源匹配pp1时，创建pp2为延时生效、抢占模式，则资源在变更时生效pp2的策略