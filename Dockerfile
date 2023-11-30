# build the kafka-debugger tooll first
FROM docker.io/golang:1.21 as kafka
WORKDIR /work

COPY ./kafka-debugger .
RUN CGO_ENABLED=0 go build -ldflags='-s -w'

# the actual debug container
FROM docker.io/alpine:3
RUN apk add --no-cache bash jq postgresql redis pgbouncer ca-certificates

WORKDIR /app
COPY bin/ .
COPY --from=kafka /work/kafka-debugger bin/

ENTRYPOINT ["/app/db_shell.sh"]
