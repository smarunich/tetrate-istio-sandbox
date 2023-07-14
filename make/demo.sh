#!/usr/bin/env bash
set -e

export ROOT_DIR="$(
	cd -- "$(dirname "${0}")" >/dev/null 2>&1
	pwd -P
)"
source ${ROOT_DIR}/variables.sh

export ACTION=${1}

if [[ ${ACTION} = "describe" ]]; then
	source ${ROOT_DIR}/describe.sh demo
fi

if [[ ${ACTION} = "deploy_bookinfo" ]]; then
	export CLUSTER_INDEX=0
  # Initialize demo directory
  run_command_at_jumpbox $CLUSTER_INDEX "if [ ! -d demo ]; then git clone ${GIT_REPO}; cp -r tetrate-service-express-sandbox/demo . ;fi"
  #kubectl create namespace bookinfo
  #kubectl label namespace bookinfo istio-injection=enabled
  run_command_at_jumpbox $CLUSTER_INDEX 'cd /tmp; echo $PWD'
fi