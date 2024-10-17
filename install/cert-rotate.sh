#!/bin/bash

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.1/cert-manager.yaml


cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: ca-issuer-sample
  namespace: karmada-system
spec:
  ca:
    secretName: ca-key-pair
EOF

#证书有效期 duration 设置为 60m
#证书轮换的提前时间 renewBefore 设置为 59m，也就是每分钟轮换一次
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: client-cert
  namespace: karmada-system
spec:
  secretName: client-cert
  privateKey:
    algorithm: RSA
    size: 3072
  issuerRef:
    name: ca-issuer
    kind: Issuer
    group: cert-manager.io
  duration: 60m
  renewBefore: 59m
  commonName: system:admin
  subject:
    organizations:
      - system:masters
  usages:
    - signing
    - key encipherment
    - client auth
EOF
