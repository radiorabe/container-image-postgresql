FROM quay.io/sclorg/postgresql-16-c9s:20240731 as source
FROM ghcr.io/radiorabe/ubi9-minimal:0.7.2 AS app

ENV CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/postgresql \
    HOME=/var/lib/pgsql \
    POSTGRESQL_VERSION=16 \
    POSTGRESQL_PREV_VERSION=15 \
    PGUSER=postgres \
    APP_DATA=/opt/app-root


COPY --from=source /usr/share/container-scripts /usr/share/container-scripts
COPY --from=source /usr/libexec/check-container /usr/libexec/check-container
COPY --from=source /usr/bin/cgroup-limits /usr/bin/cgroup-limits
COPY --from=source /usr/bin/container-entrypoint /usr/bin/container-entrypoint
COPY --from=source /usr/bin/run-postgresql /usr/bin/run-postgresql

RUN    microdnf install -y \
         bind-utils \
         findutils \
         gettext \
         glibc-langpack-en \
         glibc-locale-source \
         nss_wrapper \
         postgresql-server \
         postgresql-contrib \
         pgaudit \
         rsync \
         tar \
    && localedef -f UTF-8 -i en_US en_US.UTF-8 \
    && mkdir -p /var/lib/pgsql/data \
    && microdnf clean all \
    && [[ "$(id postgres)" == "uid=26(postgres) gid=26(postgres) groups=26(postgres)" ]]

USER 26
ENTRYPOINT ["container-entrypoint"]
CMD ["run-postgresql"]
