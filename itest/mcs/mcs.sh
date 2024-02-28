#!/bin/zsh

case=$1

export KUBECONFIG=~/.kube/karmada.config:~/.kube/members.config

alias ka='kubectl --context karmada-apiserver'
alias kh='kubectl --context karmada-host'
alias km1='kubectl --context member1'
alias km2='kubectl --context member2'
alias km3='kubectl --context member3'
alias km4='kubectl --context member4'

function myecho(){
  echo -e $1
  echo -e $1 >> out.log
  echo -e "\n" >> out.log
}

function assert() {
  if [[ $1 ]]; then
    myecho 'Success.'
  else
    myecho 'Failed.'
    exit 1
  fi
}

echo "" > out.log

if [[ $case == '' || $case == '1' ]]; then
  myecho "---------1 deploy变更/集群中某个Pod实例重启地址发送变化----------\n"

  ka apply -f mcs1.yaml
  sleep 4

  before=$(karmadactl get endpointslice | grep member1-nginx | awk '{print $5}')
  myecho "${before}"

  km1 delete po $(km1 get po | grep nginx | awk '{print $1}') --force --grace-period=0
  sleep 4

  after=$(karmadactl get endpointslice | grep member1-nginx | awk '{print $5}')
  myecho "${after}"

  assert ${before}==${after}

  ka delete -f mcs1.yaml
fi

if [[ $case == '' || $case == '2' ]]; then
  myecho "---------2 deploy变更/升级Deployment，增加或减少部署Pod实例数----------\n"

  ka apply -f mcs2.yaml
  sleep 4

  before=$(karmadactl get endpointslice)
  myecho "${before}"

  ka scale deploy nginx --replicas=2
  sleep 4

  after=$(karmadactl get endpointslice)
  myecho "${after}"

  ka scale deploy nginx --replicas=4
  sleep 4

  after2=$(karmadactl get endpointslice)
  myecho "${after2}"

  ka delete -f mcs2.yaml
fi