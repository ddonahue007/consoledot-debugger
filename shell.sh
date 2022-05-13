#!/usr/bin/env bash
set -x

if [[ -z $ACG_CONFIG ]]; then
    echo "need ACG_CONFIG (aka clowder)"
    exit 1
fi

# this is hacky - but should work
export PGPASSWORD=$(cat $ACG_CONFIG | jq .database.password | tr -d '"')

export USER=$(cat $ACG_CONFIG | jq .database.username | tr -d '"')
export HOST=$(cat $ACG_CONFIG | jq .database.hostname | tr -d '"')
export PORT=$(cat $ACG_CONFIG | jq .database.port | tr -d '"')
export NAME=$(cat $ACG_CONFIG | jq .database.name | tr -d '"')

psql --host=$HOST --user=$USER --dbname=$NAME --port=$PORT
