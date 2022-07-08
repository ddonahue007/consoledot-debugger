#!/usr/bin/env bash 

oc debug deploy/sources-api-svc -t --image quay.io/jlindgren/db-debug:psql -- /app/shell.sh
