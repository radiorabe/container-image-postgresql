FROM quay.io/sclorg/postgresql-16-c10s:20260415@sha256:924ca9c2bf7683547f175fc73d5bad25ebe1bdecc95e85c2e8d51b67ebcfc4b8 AS source
FROM ghcr.io/radiorabe/ubi10-minimal:0.1.5@sha256:aef2bdbd2136692fbd5af48cd63e8c1c2c7c0e46306bb77563615fbcdc961f06 AS app

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

RUN <<-EOR
    set -xe
    microdnf install -y \
         bind-utils \
         findutils \
         gettext-envsubst \
         glibc-langpack-en \
         glibc-locale-source \
         nss_wrapper-libs \
         postgresql-server \
         postgresql-contrib \
         postgresql-upgrade \
         pgaudit \
         pgvector \
         rsync \
         tar \
         xz
    localedef -f UTF-8 -i en_US en_US.UTF-8
    mkdir -p /run/postgresql /var/lib/pgsql/data
    postgres -V | grep -qe "$POSTGRESQL_VERSION\." && echo "Found VERSION $POSTGRESQL_VERSION"
    microdnf clean all
    test "$(id postgres)" = "uid=26(postgres) gid=26(postgres) groups=26(postgres)"
EOR

USER 26
ENTRYPOINT ["container-entrypoint"]
CMD ["run-postgresql"]
