#!/bin/bash

if [ "$1" == "" ]; then
  kubectl --context karmada-apiserver apply -f spark-app.yaml

  while [[ $(kubectl --context karmada-apiserver get svc | grep -c "driver-svc") -eq 0 ]]; do echo "wait driver svc ready.."; sleep 1; done
  name=$(kubectl --context karmada-apiserver get svc | grep "driver-svc" | awk '{print $1}')
  sed -e "s/spark-test-driver-svc/${name}/g" mcs.yaml > mcs-tmp.yaml
  kubectl --context karmada-apiserver apply -f mcs-tmp.yaml
else
  kubectl --context karmada-apiserver delete -f mcs-tmp.yaml
  kubectl --context karmada-apiserver delete -f spark-app.yaml
fi
