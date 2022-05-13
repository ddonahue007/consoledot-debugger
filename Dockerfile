FROM docker.io/debian:11
RUN apt update && apt -yqq install jq postgresql-client-13

WORKDIR /app
COPY shell.sh .

ENTRYPOINT ["/app/shell.sh"]
