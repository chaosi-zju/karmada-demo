#!/bin/bash

ka patch cluster member2 --type='json' -p '[{"op": "replace", "path": "/spec/apiEndpoint", "value": "https://172.18.1.2:6443"}]'
ka patch cluster member2 --type='json' -p '[{"op": "replace", "path": "/spec/apiEndpoint", "value": "https://172.18.0.2:6443"}]'

km1 scale deploy metrics-server --replicas=0 -n kube-system

ka patch deploy nginx --type='json' -p '[{"op": "replace", "path": "/spec/replicas", "value": 2}]'
