#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

SCRIPTS_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_DIR="${SCRIPTS_DIR}/.."

CMD=${1:-help}
export VERBOSE=${VERBOSE:-""}

# import common & logging
source "${SCRIPTS_DIR}"/common/logging.sh
source "${SCRIPTS_DIR}"/common/utils.sh

usage() {
    log-info "Usage: $(basename "$0") <command> [command_arg]"
    log-info ""
    log-info "commands:"
    log-info "\t run <DBSECRET>    run console-debugger pod"
    log-info "\t build             build console-debugger image and push it"
    log-info "\t help              show this usage"
}

# default: kubectl'
KUBE_CLI_CMD=${KUBE_CLI_CMD:-kubectl}

# default: 'quay.io/jlindgren/consoledot-debugger:latest'
IMAGE=${IMAGE:-quay.io/jlindgren/consoledot-debugger:latest}

# default: 'podman'
CONTAINER_CMD=${CONTAINER_CMD:-podman}

# default: 'db-debug'
POD_NAME=${POD_NAME:-db-debug}

build(){
  if [ "${CONTAINER_CMD}" = "podman" ]; then
    log-info "building with podman..."
    log-debug "${CONTAINER_CMD} build . -t ${IMAGE}"
  	${CONTAINER_CMD} build . -t "${IMAGE}"
  	log-debug "${CONTAINER_CMD} push ${IMAGE}"
  	${CONTAINER_CMD} push "${IMAGE}"
  else
    log-info "building with docker..."
    log-debug "${CONTAINER_CMD} buildx build --push --platform linux/amd64 . -t ${IMAGE}"
	  ${CONTAINER_CMD} buildx build --push --platform linux/amd64 . -t ${IMAGE}
	fi
}

run() {
  log-info "running..."
  if [[ -z "${1}" ]]; then
    log-err "need to provide db secret name"
    exit 1
  fi

  clowdapp=$(head -c -4 <<< $1)

  cat ./templates/db-debug-pod.yml |
  sed "s|DBSECRET|${1}|g;s|IMAGE|${IMAGE}|g;s|POD_NAME|${POD_NAME}|g;s|CLOWDAPP|${clowdapp}|g"| ${KUBE_CLI_CMD} create -f -

  log-debug "${KUBE_CLI_CMD} wait --for=condition=Ready pod/${POD_NAME}"
  ${KUBE_CLI_CMD} wait --for=condition=Ready pod/"${POD_NAME}"

  log-debug "${KUBE_CLI_CMD} exec -it ${POD_NAME} -- bash"
  ${KUBE_CLI_CMD} exec -it "${POD_NAME}" -- bash

  log-debug "${KUBE_CLI_CMD} delete -f ./templates/db-debug-pod.yml --wait=false"
  ${KUBE_CLI_CMD} delete -f ./templates/db-debug-pod.yml --wait=false
}

#
# execute
#
case ${CMD} in
  "run") run "${2}" ;;
  "build") build ;;
  "help") usage ;;
   *) usage ;;
esac
