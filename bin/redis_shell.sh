#!/usr/bin/env bash

if [[ -z $ACG_CONFIG ]]; then
    echo "need ACG_CONFIG (aka clowder)"
    exit 1
fi

export CACHE_HOST=$(cat $ACG_CONFIG | jq .inMemoryDb.hostname | tr -d '"')
export CACHE_PORT=$(cat $ACG_CONFIG | jq .inMemoryDb.port | tr -d '"')

redis-cli -h $CACHE_HOST -p $CACHE_PORT

