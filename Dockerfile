FROM docker.io/alpine:3
RUN apk add --no-cache bash jq postgresql redis pgbouncer ca-certificates

WORKDIR /app
COPY bin/ .

ENTRYPOINT ["/app/db_shell.sh"]
