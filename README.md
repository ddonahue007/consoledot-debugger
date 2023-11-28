# Consoledot-debugger

## Overview
This tool will deploy a pod onto the cluster in the current namspace|project. 
Once this pod has been deployed you are automatically logged into the pod. 
The tools provided by this pod alow access to the database, redis and others.

### Requirements
- [Docker](https://docs.docker.com/engine/install/) or [podman](https://podman.io/getting-started/installation)
- [oc](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.5/html/installing_on_rhv/cli-installing-cli_installing-rhv-default) or [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Active [quay.io](https://quay.io/) account.
  - Make sure after your first build you switch the repository access to be public

### Setup
The following environment variables have default values. You may override the 
defaults by setting them in your environment as follows.

- KUBE_CLI_CMD (default: kubectl)
```shell
export KUBE_CLI_CMD="oc"
```

- CONTAINER_CMD (default: podman)
```shell
export CONTAINER_CMD="docker"
```

- IMAGE (default: quay.io/jlindgren/consoledot-debugger:latest)
```shell
export IMAGE="quay.io/bilbo/consoledot-debugger:latest"
```

### login to cluster and set project context
You must log into the cluster that you would like to debug and retrieve your 
login token. Once you have run that command in a terminal and are 
able to run oc|kubectl commands you are ready to move on.

- get list of projects
```shell
oc projects
```
- Switch to the project you are going to debug
```shell
oc project <name of project>
```

### Ruilding
- build debugger image
```shell
make all
```

### Running
- retrieve the db secret name for you project|namespace (exanple using oc command)
```shell
oc get secret 
```
- run debugger (example with db secret name)
```shell
make debug DBSECRET="test-engine-db"
```
You will be placed into the pod with a prompt like below:
```shell
db-debug:/app$
```

- exit the pod by hitting `Control D`
```shell
db-debug:/app$^D
```
The pod should automatically be removed from the cluster,but if not you can 
run the following command.
```shell
oc delete pod db-debug
```