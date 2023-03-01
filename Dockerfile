FROM registry.fedoraproject.org/fedora:37
RUN dnf -y install jq postgresql redis pgbouncer && dnf clean all

WORKDIR /app
COPY bin/ .

ENTRYPOINT ["/app/db_shell.sh"]
