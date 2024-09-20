#!/bin/bash

#export NEED_CREATE_KIND_CLUSTER=true
#export INSTALL_ESTIMATOR=true

IMAGE_FROM="-" CLUSTER_VERSION="kindest/node:v1.28.6" hack/local-up-karmada-helm.sh
