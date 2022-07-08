#!/usr/bin/env bash
set -x

if [[ -z $ACG_CONFIG ]]; then
    echo "need ACG_CONFIG (aka clowder)"
    exit 1
fi

# this is hacky - but should work
export PGPASSWORD=$(cat $ACG_CONFIG | jq .database.password | tr -d '"')

export PGUSER=$(cat $ACG_CONFIG | jq .database.username | tr -d '"')
export PGHOST=$(cat $ACG_CONFIG | jq .database.hostname | tr -d '"')
export PGPORT=$(cat $ACG_CONFIG | jq .database.port | tr -d '"')
export PGDATABASE=$(cat $ACG_CONFIG | jq .database.name | tr -d '"')

if [[ -z $1 ]]; then
    psql 
else
    pgcli
fi
