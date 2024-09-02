#!/bin/bash

export KUBECONFIG=~/.kube/karmada.config:~/.kube/members.config
alias ka='kubectl --context karmada-apiserver'
alias km1='kubectl --context member1'
alias km2='kubectl --context member2'
alias km3='kubectl --context member3'
shopt -s  expand_aliases

kh patch deploy karmada-controller-manager -n karmada-system --type='json' -p '[
   {"op": "replace", "path": "/spec/template/spec/containers/0/command/3", "value": "--cluster-status-update-frequency=3s"},
   {"op": "replace", "path": "/spec/template/spec/containers/0/command/5", "value": "--failover-eviction-timeout=3s"},
   {"op": "add", "path": "/spec/template/spec/containers/0/command/6", "value": "--cluster-failure-threshold=3s"},
   {"op": "add", "path": "/spec/template/spec/containers/0/command/7", "value": "--cluster-success-threshold=3s"}]'

kh patch deploy karmada-controller-manager -n karmada-system --type='json' -p '[
   {"op": "add", "path": "/spec/template/spec/containers/0/command/6", "value": "--graceful-eviction-timeout=3s"}]'


ka patch cluster member2 --type='json' -p '[{"op": "replace", "path": "/spec/apiEndpoint", "value": "https://172.18.0.4:6444"}]'

ka patch rb demo-test-1-deployment --type='json' -p '[{"op": "replace", "path": "/spec/clusters", "value": [{"name": "member2", "replicas": 3}]}]'

ka patch rb demo-test-1-deployment --type='json' -p '[{"op": "replace", "path": "/spec/clusters", "value": [{"name": "member1", "replicas": 1}, {"name": "member2", "replicas": 2}]}]'

ka patch rb demo-test-1-deployment --type='json' -p '[{"op": "replace", "path": "/spec/rescheduleTriggeredAt", "value": "2024-04-18T11:38:15Z"}]'

ka patch cluster member2 --type='json' -p '[{"op": "replace", "path": "/spec/taints", "value": [{"key": "workload-rebalancer-test", "effect": "NoSchedule"}]}]'
ka patch cluster member2 --type='json' -p '[{"op": "replace", "path": "/spec/taints", "value": []}]'
ka patch cluster member1 --type='json' -p '[{"op": "replace", "path": "/spec/taints", "value": []}]'

ka patch deploy nginx --type='json' -p '[{"op": "replace", "path": "/spec/replicas", "value": 3}]'
km1 patch deploy nginx --type='json' -p '[{"op": "replace", "path": "/spec/replicas", "value": 3}]'
