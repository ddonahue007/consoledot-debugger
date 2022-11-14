FROM registry.fedoraproject.org/fedora:36
RUN dnf -y install jq postgresql redis && dnf clean all

WORKDIR /app
COPY bin/ .

ENTRYPOINT ["/app/db_shell.sh"]
