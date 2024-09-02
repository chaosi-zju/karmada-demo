#!/bin/bash




kh patch deploy karmada-controller-manager -n karmada-system --type='json' -p '[{"op": "replace", "path": "/spec/template/spec/containers/0/ports", "value": [{"containerPort": 8080, "name": "metrics", "protocol": "TCP"}]}]'
kh apply --server-side -f bundle.yaml
kh get prometheus prometheus
kh port-forward service/prometheus --address 0.0.0.0 9090
