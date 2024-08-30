# syntax=docker/dockerfile:1

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
######################################################################

# Stage 1: Base Image Setup
ARG DEBIAN_IMAGE_VERSION=bookworm-20240812
FROM debian:${DEBIAN_IMAGE_VERSION} AS dependencies

# Arguments with default values.
ARG SANCTUARY_USER=sanctuary
ARG SANCTUARY_GROUP=sanctuary
ARG SANCTUARY_UID=65532
ARG SANCTUARY_GID=65532
ARG SANCTUARY_HOME=/home/${SANCTUARY_USER}
ARG SANCTUARY_BIN=${SANCTUARY_HOME}/bin
ARG SANCTUARY_CONFIG=${SANCTUARY_HOME}/config
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
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    DEBIAN_PRIORITY=critical \
    DEBCONF_NOWARNINGS=yes \
    TERM=xterm-256color \
    APT_LISTCHANGES_FRONTEND=none \
    APT_LISTBUGS_FRONTEND=none \
    TMPDIR=/tmp \
    LANG=${LANG} \
    LANGUAGE=${LANGUAGE} \
    TZ=${TZ}

# Ensure the build process uses the root user.
USER root

# Set safer shell options for script execution.
SHELL ["/bin/bash", "-o", "errexit", "-o", "errtrace", "-o", "functrace", "-o", "nounset", "-o", "pipefail", "-c"]

# Create a non-root user with specific configurations.
RUN groupadd \
    --gid ${SANCTUARY_GID} ${SANCTUARY_GROUP} \
    && useradd \
    --no-log-init \
    --create-home \
    --uid ${SANCTUARY_UID} \
    --gid ${SANCTUARY_GID} \
    --comment "Non-root User for Running Applications" \
    --home ${SANCTUARY_HOME} \
    --skel /etc/skel \
    --shell /bin/bash \
    ${SANCTUARY_USER}

# Set the working directory to the sanctuary home directory.
WORKDIR ${SANCTUARY_HOME}

# Copy the scripts from the local bin directory to the container's bin directory.
COPY --chown=${SANCTUARY_USER}:${SANCTUARY_GROUP} bin ${SANCTUARY_BIN}

# Make sure the scripts are executable.
RUN chmod --recursive +x ${SANCTUARY_BIN}/*

# Copy apt.conf and dpkg.cfg to their respective locations.
COPY config/apt.conf /etc/apt/apt.conf.d/99docker-apt.conf
COPY config/dpkg.cfg /etc/dpkg/dpkg.cfg.d/99docker-dpkg.cfg

# Copy the package list to the container.
COPY package.list /${TMPDIR}/package.list

# Log the current APT configuration.
RUN apt-config dump > /var/log/apt-config.log

# Optional: Display the log file (for CI/CD or debugging purposes).
RUN cat /var/log/apt-config.log

# Configure the locale and timezone.
RUN apt-get update \
    && apt-get install \
    locales=2.36-9+deb12u7 \
    locales-all=2.36-9+deb12u7 \
    && rm -rf /var/lib/apt/lists/* \
    && "${SANCTUARY_BIN}/tools/configure_locale.sh" \
    && "${SANCTUARY_BIN}/tools/set_timezone.sh"

RUN apt-get update \
    && apt-get install \
    ca-certificates=20230311 \
    cmake=3.25.1-1 \
    build-essential=12.9 \
    git=1:2.39.2-1.1 \
    libssl-dev=3.0.13-1~deb12u1 \
    libbz2-dev=1.0.8-5+b1 \
    liblz4-dev=1.9.4-1 \
    libzstd-dev=1.5.4+dfsg2-5 \
    zlib1g-dev=1:1.2.13.dfsg-1 \
    libcurl4-openssl-dev=7.88.1-10+deb12u6 \
    liblz4-dev=1.9.4-1 \
    libbz2-dev=1.0.8-5+b1 \
    libboost-all-dev=1.74.0.3 \
    libblosc-dev=1.21.3+ds-1 \
    zip=3.0-13 \
    unzip=6.0-28 \
    pkg-config=1.8.1-1 \
    ninja-build=1.11.1-1 \
    && rm -rf /var/lib/apt/lists/*

# Stage 2: Building the Base Image
FROM dependencies as base

# Switch to the non-root user.
USER ${SANCTUARY_USER}:${SANCTUARY_GROUP}

# Set Bash as the entry point to keep the container running.
ENTRYPOINT [ "bash", "-c", "tail -f /dev/null" ]
