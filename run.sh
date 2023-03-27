#!/usr/bin/env bash 
set -x

if [[ -z $1 ]]; then
    echo "need db secret"
    exit 1
fi

cat ./templates/db-debug-pod.yml | sed "s/DBSECRET/$1/g" | k create -f - 

kubectl wait --for=condition=Ready pod/db-debug
kubectl exec -it db-debug -- bash
kubectl delete -f ./templates/db-debug-pod.yml --wait=false
