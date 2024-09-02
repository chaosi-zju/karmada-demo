#!/bin/bash

export KUBECONFIG=~/.kube/karmada.config:~/.kube/members.config
alias ka='kubectl --context karmada-apiserver'
alias km1='kubectl --context member1'
alias km2='kubectl --context member2'
alias km3='kubectl --context member3'
shopt -s  expand_aliases

# ${ns} namespaces
ns=1
# each namespace has ${dnum} deployment
dnum=200
# sum group of resource
#k=0

if [[ $1 == "clean" ]]; then
  for i in $(seq 1 $ns)
  do
    nsName="ns-${i}"
    ka delete deployment,secret,configmap,service,serviceexport --all -n ${nsName}
#    ka delete -f cpp.yaml || true
    ka delete rb --all -n ${nsName}
#    km1 delete deployment,secret,configmap,service --all -n ${nsName}
#    km2 delete deployment,secret,configmap,service --all -n ${nsName}
#    km3 delete deployment,secret,configmap,service --all -n ${nsName}
#    rm -rf ~/.kube/cache ~/.kube/http-cache
  done
  exit 0
fi

ka apply -f cpp.yaml

# iterate each namespace
for i in $(seq 1 $ns)
do
  nsName="ns-${i}"
  # create namespace if it not exist
  ka create ns ${nsName} --dry-run=client -o yaml | ka apply -f -

  # create each resource in certain namespace
  for j in $(seq 1 $dnum)
  do
      cp -f demo-test.yaml demo-test-tmp.yaml

      sed -i'' -e "s/demo-test-ns/${nsName}/g" demo-test-tmp.yaml
      sed -i'' -e "s/demo-test-2/test-${i}-${j}-2/g" demo-test-tmp.yaml
      sed -i'' -e "s/demo-test/test-${i}-${j}/g" demo-test-tmp.yaml

      ka apply -f demo-test-tmp.yaml

#      k=$((k+1))
#      if [ $((k%1000)) -eq 0 ]; then
#        read -p "Press any key to continue..." -n 1 -r
#      fi
  done
done
