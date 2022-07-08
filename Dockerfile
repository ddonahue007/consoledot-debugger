FROM registry.fedoraproject.org/fedora:36
RUN dnf -y install jq postgresql && dnf clean all

WORKDIR /app
COPY shell.sh .

ENTRYPOINT ["/app/shell.sh"]
