#!/bin/bash

km1 create namespace argo-rollouts
km1 apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

ka create namespace argo-rollouts
ka apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
