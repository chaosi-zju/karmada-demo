#!/bin/bash

# 安装
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.1/cert-manager.yaml

kubectl apply -f ./cert.yaml


# 手动更新 secret/karmada-config
ca_crt=`kh get secret client-cert -n karmada-system -o jsonpath='{.data.ca\.crt}'`
client_crt=`kh get secret client-cert -n karmada-system -o jsonpath='{.data.tls\.crt}'`
client_key=`kh get secret client-cert -n karmada-system -o jsonpath='{.data.tls\.key}'`

cp -f karmada-secret-config.yaml karmada-secret-config-tmp.yaml
sed -i'' -e "s/{{ca_crt}}/${ca_crt}/g" ./karmada-secret-config-tmp.yaml
sed -i'' -e "s/{{client_crt}}/${client_crt}/g" ./karmada-secret-config-tmp.yaml
sed -i'' -e "s/{{client_key}}/${client_key}/g" ./karmada-secret-config-tmp.yaml

kubectl apply -f ./karmada-secret-config-tmp.yaml

# 重启所有组件
kh delete po etcd-0 -n karmada-system
kh delete po `kh get po -n karmada-system | grep karmada-apiserver | awk '{print $1}'` -n karmada-system
kh delete po `kh get po -n karmada-system | grep -v karmada-apiserver | grep -v etcd-0 | grep -v NAME | awk '{print $1}'` -n karmada-system
