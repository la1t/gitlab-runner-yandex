FROM alpine:3.15.2

RUN adduser -D -S -h /home/gitlab-runner gitlab-runner

RUN apk add --no-cache \
    bash \
    ca-certificates \
    tzdata \
    openssh-client \
    curl

ARG TARGETPLATFORM
ARG GITLAB_RUNNER_VERSION
ARG DOCKER_MACHINE_VERSION
ARG DUMB_INIT_VERSION
ARG DOCKER_MACHINE_DRIVER_YANDEX_VERSION

COPY --chmod=777 install-deps /tmp/

# Install GNU wget for "-nv" flag support
RUN apk add --no-cache --virtual .fetch-deps wget && \
    /tmp/install-deps \ 
        "${TARGETPLATFORM}" \
        "${GITLAB_RUNNER_VERSION}" \
        "${DOCKER_MACHINE_VERSION}" \
        "${DUMB_INIT_VERSION}" \
        "${DOCKER_MACHINE_DRIVER_YANDEX_VERSION}" && \
    apk del .fetch-deps

RUN rm -rf /tmp/*

FROM alpine:3.15.2

COPY --from=0 / /
COPY --chmod=777 entrypoint /

STOPSIGNAL SIGQUIT
VOLUME ["/etc/gitlab-runner", "/home/gitlab-runner"]
ENTRYPOINT ["/usr/bin/dumb-init", "/entrypoint"]
CMD ["run", "--user=gitlab-runner", "--working-directory=/home/gitlab-runner"]
