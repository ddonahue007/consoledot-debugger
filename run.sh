#!/usr/bin/env bash 
set -x

if [[ -z $1 ]]; then
    echo "need db secret"
    exit 1
fi

cat ./templates/db-debug-pod.yml | sed "s/DBSECRET/$1/g" | k create -f - 
