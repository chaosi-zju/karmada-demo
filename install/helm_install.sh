#!/bin/bash

#export NEED_CREATE_KIND_CLUSTER=true
#export INSTALL_ESTIMATOR=true
export IMAGE_FROM=""
export CLUSTER_VERSION="kindest/node:v1.28.6"
hack/local-up-karmada-helm.sh
