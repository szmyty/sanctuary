# syntax=docker/dockerfile:1.3
# check=error=true
# escape=\
######################################################################
# @Project      : sanctuary
# @File         : Dockerfile
# @Description  : Dockerfile for building a secure and efficient container.
#                 Includes custom APT and DPKG configurations, installs
#                 necessary packages from a package list, and sets up a
#                 non-root user for running applications.
#
# @Author       : Alan Szmyt
# @Date         : 2024-08-23
# @Version      : 1.0
#
# @References   :
#   - https://docs.docker.com/reference/dockerfile/
#   - https://docs.docker.com/build/building/best-practices/
#   - https://docs.docker.com/develop/develop-images/multistage-build/
######################################################################

# Stage 1: Base Image Setup
ARG DEBIAN_IMAGE_VERSION=@sha256:21887a619d762d236e7c66666ca657622ed8749e788322400b86ab09283d8fba
ARG PLATFORM=linux/amd64

FROM --platform=${BUILDPLATFORM} debian:${DEBIAN_IMAGE_VERSION} AS setup

# Define ARG variables
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG BUILDPLATFORM
ARG BUILDOS
ARG BUILDARCH
ARG BUILDVARIANT

# Set labels using OCI conventions and incorporating ARG variables
# https://github.com/opencontainers/image-spec/blob/v1.0.1/annotations.md
# https://specs.opencontainers.org/image-spec/annotations/
LABEL \
    org.opencontainers.image.created="2024-08-23" \
    org.opencontainers.image.authors="Alan Szmyt" \
    org.opencontainers.image.url="https://example.com/myimage" \
    org.opencontainers.image.documentation="https://example.com/myimage/docs" \
    org.opencontainers.image.source="https://github.com/example/myimage" \
    org.opencontainers.image.version="1.0" \
    org.opencontainers.image.revision="abc1234" \
    org.opencontainers.image.vendor="Example, Inc." \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.title="${COMPOSE_PROJECT_NAME}" \
    org.opencontainers.image.description="This image is used for..." \
    org.opencontainers.image.base.name="debian:bookworm" \
    org.opencontainers.image.target.platform="${TARGETPLATFORM}" \
    org.opencontainers.image.target.os="${TARGETOS}" \
    org.opencontainers.image.target.arch="${TARGETARCH}" \
    org.opencontainers.image.target.variant="${TARGETVARIANT}" \
    org.opencontainers.image.build.platform="${BUILDPLATFORM}" \
    org.opencontainers.image.build.os="${BUILDOS}" \
    org.opencontainers.image.build.arch="${BUILDARCH}" \
    org.opencontainers.image.build.variant="${BUILDVARIANT}"

# Arguments with default values.
ARG SANCTUARY_USER=sanctuary
ARG SANCTUARY_GROUP=sanctuary
ARG SANCTUARY_UID=65532
ARG SANCTUARY_GID=65532
ARG SANCTUARY_HOME=/home/${SANCTUARY_USER}
ARG SANCTUARY_BIN=${SANCTUARY_HOME}/bin
ARG SANCTUARY_CONFIG=${SANCTUARY_HOME}/config
ARG SANCTUARY_TOOLS_BIN=${SANCTUARY_BIN}/tools
ARG SANCTUARY_HARDENING_BIN=${SANCTUARY_BIN}/hardening
ARG SANCTUARY_LOGS=${SANCTUARY_HOME}/logs
ARG SANCTUARY_DATA=${SANCTUARY_HOME}/data
ARG TMPDIR=/tmp
ARG LANG=en_US.UTF-8
ARG LANGUAGE=en_US:en
ARG TZ=UTC

# Set environment variables.
ENV BASE_IMAGE_VERSION=${BASE_IMAGE_VERSION} \
    SANCTUARY_USER=${SANCTUARY_USER} \
    SANCTUARY_GROUP=${SANCTUARY_GROUP} \
    SANCTUARY_UID=${SANCTUARY_UID} \
    SANCTUARY_GID=${SANCTUARY_GID} \
    SANCTUARY_HOME=${SANCTUARY_HOME} \
    SANCTUARY_BIN=${SANCTUARY_BIN} \
    SANCTUARY_CONFIG=${SANCTUARY_CONFIG} \
    SANCTUARY_TOOLS_BIN=${SANCTUARY_TOOLS_BIN} \
    SANCTUARY_HARDENING_BIN=${SANCTUARY_HARDENING_BIN} \
    SANCTUARY_LOGS=${SANCTUARY_LOGS} \
    SANCTUARY_DATA=${SANCTUARY_DATA} \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    DEBIAN_PRIORITY=critical \
    DEBCONF_NOWARNINGS=yes \
    TERM=xterm-256color \
    APT_LISTCHANGES_FRONTEND=none \
    APT_LISTBUGS_FRONTEND=none \
    TMPDIR=${TMPDIR} \
    LANG=${LANG} \
    LANGUAGE=${LANGUAGE} \
    TZ=${TZ}

# Ensure the build process uses the root user.
USER root

# Set safer shell options for script execution.
SHELL ["/bin/bash", "-o", "errexit", "-o", "errtrace", "-o", "functrace", "-o", "nounset", "-o", "pipefail", "-c"]

# Create necessary directories and set permissions.
RUN mkdir --parents ${SANCTUARY_HOME} \
    && mkdir --parents ${SANCTUARY_BIN} \
    && mkdir --parents ${SANCTUARY_CONFIG} \
    && mkdir --parents ${SANCTUARY_TOOLS_BIN} \
    && mkdir --parents ${SANCTUARY_HARDENING_BIN} \
    && mkdir --parents ${SANCTUARY_LOGS} \
    && mkdir --parents ${SANCTUARY_DATA} \
    # Set ownership to the sanctuary user and group
    && chown --recursive ${SANCTUARY_USER}:${SANCTUARY_GROUP} ${SANCTUARY_HOME} \
    # Set permissions: read, write, and execute for owner, and read-only for group and others
    && chmod --recursive 700 ${SANCTUARY_HOME} \
    # Allow execution of binaries and scripts
    && chmod --recursive 755 ${SANCTUARY_BIN}

# Create a non-root user with specific configurations.
RUN groupadd \
    --gid ${SANCTUARY_GID} \
    --force ${SANCTUARY_GROUP} \
    && useradd \
    --no-log-init \
    --create-home \
    --uid ${SANCTUARY_UID} \
    --gid ${SANCTUARY_GID} \
    --comment "Non-root User for Running Applications" \
    --home-dir ${SANCTUARY_HOME} \
    --shell /usr/sbin/nologin \
    ${SANCTUARY_USER}

# Set the working directory to the sanctuary home directory.
WORKDIR ${SANCTUARY_HOME}

# TODO for security, we could have a specific user that is allowed to use the scripts and so you are forced to switch to that user to run the scripts. This will enforce extending the base image to utilize the scripts.
# Copy the scripts from the local bin directory to the container's bin directory.
COPY --chown=${SANCTUARY_USER}:${SANCTUARY_GROUP} --chmod=500 bin ${SANCTUARY_BIN}

# Copy apt.conf and dpkg.cfg to their respective locations.
COPY --chown=root:root --chmod=644  config/apt.conf /etc/apt/apt.conf.d/99docker-apt.conf
COPY --chown=root:root --chmod=644  config/dpkg.cfg /etc/dpkg/dpkg.cfg.d/99docker-dpkg.cfg

# Set the environment variable for the global Git config location for all users
ENV GIT_CONFIG=${SANCTUARY_CONFIG}/.gitconfig

# Copy the Git config file to a common location accessible by all users
COPY --chown=root:root --chmod=644 config/.gitconfig ${GIT_CONFIG}

# Disable the automatic removal of downloaded packages
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Stage 2: Installing APT Dependencies.
FROM setup AS apt-install

# Install packages using cached directories and configure locale and timezone.
# TODO set versions per platform
# https://docs.docker.com/build/building/best-practices/#apt-get
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-cache \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-lib \
    apt-get update \
    && apt-get install --yes \
    apt-utils \
    build-essential \
    bzip2 \
    ca-certificates \
    ccache \
    clang-format \
    clang-tidy \
    cmake \
    curl \
    dnsutils \
    doxygen \
    git \
    graphviz \
    htop \
    iputils-ping \
    libaprutil1 \
    libboost-all-dev \
    libblosc-dev \
    libbz2-dev \
    libcurl4-openssl-dev \
    libksba8 \
    liblz4-dev \
    libpng-dev \
    libpng-tools \
    libspdlog-dev \
    libssl-dev \
    libtasn1-6 \
    libtiff-dev \
    libtool \
    libzstd-dev \
    locales \
    locales-all \
    lsof \
    make \
    nano \
    net-tools \
    ninja-build \
    pkg-config \
    python3 \
    python3-dev \
    strace \
    sysstat \
    tcpdump \
    unzip \
    vim \
    wget \
    xz-utils \
    zip \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && ${SANCTUARY_TOOLS_BIN}/setup_locale.sh \
    && ${SANCTUARY_TOOLS_BIN}/set_timezone.sh

FROM apt-install AS logger

# Optional: Verify package installation from cache without internet
RUN --network=none \
    dpkg -l | grep -E 'locales|cmake|python3' > ${SANCTUARY_LOGS}/packages.log

RUN printenv | sort > ${SANCTUARY_LOGS}/environment.log

# Log the current git configuration.
RUN git config --list --show-origin > ${SANCTUARY_LOGS}/gitconfig.log

RUN dpkg --get-selections > ${SANCTUARY_LOGS}/installed_packages.log

# Log the current APT configuration.
RUN apt-config dump > ${SANCTUARY_LOGS}/apt-config.log

FROM logger as base

# Switch to the non-root user.
USER ${SANCTUARY_USER}:${SANCTUARY_GROUP}

# Set Bash as the entry point to keep the container running.
ENTRYPOINT [ "bash", "-c", "tail -f /dev/null" ]

# Healthcheck to ensure the container is running.
HEALTHCHECK \
    --interval=30s \
    --timeout=30s \
    --start-period=5s \
    --retries=3 \
    CMD ${SANCTUARY_BIN}/healthcheck.sh
