#!/bin/zsh

case=$1

export KUBECONFIG=~/.kube/karmada.config:~/.kube/members.config

alias ka='kubectl --context karmada-apiserver'
alias kh='kubectl --context karmada-host'
alias km1='kubectl --context member1'
alias km2='kubectl --context member2'
alias km3='kubectl --context member3'
alias km4='kubectl --context member4'

echo "" > out.log

if [[ $case == '' || $case == '1' ]]; then
  echo -e "---------case 1----------\n\n" >> out.log
  for i in {1..10}
  do
    ka apply -f nginx1.yaml
    sleep 2
    ka get rb nginx-deployment -o jsonpath='{.spec.clusters}' >> out.log
    km1 get po -o wide >> out.log
    km2 get po -o wide >> out.log

    ka delete -f nginx1.yaml
    sleep 1
    echo -e '\n\n---\n\n' >> out.log
  done
fi

if [[ $case == '' || $case == '2' ]]; then
  echo -e "---------case 2----------\n\n" >> out.log
  for i in {1..10}
  do
    ka apply -f nginx2.yaml
    sleep 2
    ka get rb nginx-deployment -o jsonpath='{.spec.clusters}' >> out.log
    km1 get po -o wide >> out.log
    km2 get po -o wide >> out.log
    km3 get po -o wide >> out.log

    sed 's/replicas: 3/replicas: 5/g' nginx2.yaml > nginx2-1.yaml
    ka apply -f nginx2-1.yaml
    sleep 2
    ka get rb nginx-deployment -o jsonpath='{.spec.clusters}' >> out.log
    km1 get po -o wide >> out.log
    km2 get po -o wide >> out.log
    km3 get po -o wide >> out.log

    ka delete -f nginx2-1.yaml
    sleep 1
    echo -e '\n\n---\n\n' >> out.log
  done
fi

if [[ $case == '' || $case == '3' ]]; then
  echo -e "---------case 3----------\n\n" >> out.log
  for i in {1..3}
  do
    ka apply -f nginx3.yaml
    sleep 5
    ka get rb nginx-deployment -o jsonpath='{.spec.clusters}' >> out.log
    km1 get po -o wide >> out.log
    km2 get po -o wide >> out.log
    km3 get po -o wide >> out.log
    km4 get po -o wide >> out.log
    echo -e '\n' >> out.log

    sed 's/replicas: 7/replicas: 8/g' nginx3.yaml > nginx3-1.yaml
    ka apply -f nginx3-1.yaml
    sleep 5
    ka get rb nginx-deployment -o jsonpath='{.spec.clusters}' >> out.log
    km1 get po -o wide >> out.log
    km2 get po -o wide >> out.log
    km3 get po -o wide >> out.log
    km4 get po -o wide >> out.log

    ka delete -f nginx3-1.yaml
    sleep 1
    echo -e '\n\n---\n\n' >> out.log
  done
fi

if [[ $case == '' || $case == '4' ]]; then
  echo -e "---------case 4----------\n\n" >> out.log
  for i in {1..3}
  do
    ka apply -f nginx4.yaml
    sleep 5
    ka get rb nginx-deployment -o jsonpath='{.spec.clusters}' >> out.log
    km1 get po -o wide >> out.log
    km2 get po -o wide >> out.log
    km3 get po -o wide >> out.log
    km4 get po -o wide >> out.log
    echo -e '\n' >> out.log

    sed 's/replicas: 9/replicas: 8/g' nginx4.yaml > nginx4-1.yaml
    ka apply -f nginx4-1.yaml
    sleep 5
    ka get rb nginx-deployment -o jsonpath='{.spec.clusters}' >> out.log
    km1 get po -o wide >> out.log
    km2 get po -o wide >> out.log
    km3 get po -o wide >> out.log
    km4 get po -o wide >> out.log

    ka delete -f nginx4-1.yaml
    sleep 1
    echo -e '\n\n---\n\n' >> out.log
  done
fi

if [[ $case == '' || $case == '6' ]]; then
  echo -e "---------case 6----------\n\n" >> out.log
  for i in {1..3}
  do
    ka apply -f nginx6.yaml
    sleep 5
    ka get rb nginx-deployment -o jsonpath='{.spec.clusters}' >> out.log
    km1 get po -o wide >> out.log
    km2 get po -o wide >> out.log
    km3 get po -o wide >> out.log
    km4 get po -o wide >> out.log
    echo -e '\n' >> out.log

    sed '/- member1/{n;s/weight: 1/weight: 2/;}' nginx6.yaml > nginx6-1.yaml
    ka apply -f nginx6-1.yaml
    sleep 5
    ka get rb nginx-deployment -o jsonpath='{.spec.clusters}' >> out.log
    km1 get po -o wide >> out.log
    km2 get po -o wide >> out.log
    km3 get po -o wide >> out.log
    km4 get po -o wide >> out.log

    ka delete -f nginx6-1.yaml
    sleep 1
    echo -e '\n\n---\n\n' >> out.log
  done
fi

if [[ $case == '' || $case == '7' ]]; then
  echo -e "---------case 7----------\n\n" >> out.log
  for i in {1..3}
  do
    ka apply -f nginx7.yaml
    sleep 5
    ka get rb nginx-deployment -o jsonpath='{.spec.clusters}' >> out.log
    km1 get po -o wide >> out.log
    km2 get po -o wide >> out.log
    km3 get po -o wide >> out.log
    echo -e '\n' >> out.log

    sed 's/replicas: 6/replicas: 5/g' nginx8.yaml > nginx7-1.yaml
    ka apply -f nginx7-1.yaml
    sleep 5
    ka get rb nginx-deployment -o jsonpath='{.spec.clusters}' >> out.log
    km1 get po -o wide >> out.log
    km2 get po -o wide >> out.log
    km3 get po -o wide >> out.log
    km4 get po -o wide >> out.log

    ka delete -f nginx7-1.yaml
    sleep 1
    echo -e '\n\n---\n\n' >> out.log
  done
fi

if [[ $case == '' || $case == '8' ]]; then
  echo -e "---------case 8----------\n\n" >> out.log
  for i in {1..3}
  do
    ka apply -f nginx8.yaml
    sleep 5
    ka get rb nginx-deployment -o jsonpath='{.spec.clusters}' >> out.log
    km1 get po -o wide >> out.log
    km2 get po -o wide >> out.log
    km3 get po -o wide >> out.log
    km4 get po -o wide >> out.log
    echo -e '\n' >> out.log

    sed 's/replicas: 5/replicas: 6/g' nginx7.yaml > nginx8-1.yaml
    ka apply -f nginx8-1.yaml
    sleep 5
    ka get rb nginx-deployment -o jsonpath='{.spec.clusters}' >> out.log
    km1 get po -o wide >> out.log
    km2 get po -o wide >> out.log
    km3 get po -o wide >> out.log
    km4 get po -o wide >> out.log

    ka delete -f nginx8-1.yaml
    sleep 1
    echo -e '\n\n---\n\n' >> out.log
  done
fi