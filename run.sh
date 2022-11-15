#!/usr/bin/env bash 

oc debug deploy/sources-api-svc -t --image quay.io/jlindgren/consoledot-debugger:master -- /app/db_shell.sh
