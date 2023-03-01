#!/usr/bin/env bash 

PG_CONFIG_DIR=/tmp/pgbouncer

if [[ ! -d $PG_CONFIG_DIR ]]; then 
    set -x
    mkdir -p $PG_CONFIG_DIR

    # md5 and write the password
    pass="md5$(echo -n "$PGPASSWORD$PGUSER" | md5sum | cut -f 1 -d ' ')"
    echo "\"$PGUSER\" \"$pass\"" >> ${PG_CONFIG_DIR}/userlist.txt
    echo "Wrote authentication credentials to ${PG_CONFIG_DIR}/userlist.txt"

    # pgbouncer config
    printf "\
    [databases]
    ${PGDATABASE} = host=${PGHOST} port=${PGPORT:-5432} dbname=${PGDATABASE} user=${PGUSER}
    [pgbouncer]
    listen_addr = 0.0.0.0
    listen_port = 5432
    logfile = /tmp/pgbouncer/pgbouncer.log
    pidfile = /tmp/pgbouncer/pgbouncer.pid
    auth_type = md5
    auth_file = /tmp/pgbouncer/userlist.txt
    admin_users = postgres
    ;; The following parameter allows access via newer JDBC driver
    ignore_startup_parameters = extra_float_digits
    ;; SSL parameters for connecting to the postgres database
    " > ${PG_CONFIG_DIR}/pgbouncer.ini

fi

env | grep PG
pgbouncer $PG_CONFIG_DIR/pgbouncer.ini
