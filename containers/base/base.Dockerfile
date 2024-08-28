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

# Image version to use.
ARG DEBIAN_IMAGE_VERSION=bullseye-20240812

# Using the official Debian image as base.
# https://hub.docker.com/_/debian
FROM debian:${DEBIAN_IMAGE_VERSION}

# Arguments with default values.
ARG SANCTUARY_USER=${SANCTUARY_USER:-sanctuary}
ARG SANCTUARY_GROUP=${SANCTUARY_GROUP:-sanctuary}
ARG SANCTUARY_UID=${SANCTUARY_UID:-65532}
ARG SANCTUARY_GID=${SANCTUARY_GID:-65532}
ARG SANCTUARY_HOME=/sanctuary
ARG SANCTUARY_BIN=${SANCTUARY_HOME}/bin
ARG SANCTUARY_CONFIG=${SANCTUARY_HOME}/config

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
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    LC_CTYPE=C.UTF-8 \
    LC_COLLATE=C.UTF-8 \
    LC_NUMERIC=C.UTF-8 \
    LC_TIME=C.UTF-8 \
    LC_MONETARY=C.UTF-8 \
    LC_MESSAGES=C.UTF-8 \
    LC_PAPER=C.UTF-8 \
    LC_NAME=C.UTF-8 \
    LC_ADDRESS=C.UTF-8 \
    LC_TELEPHONE=C.UTF-8 \
    LC_MEASUREMENT=C.UTF-8 \
    LC_IDENTIFICATION=C.UTF-8 \
    APT_LISTCHANGES_FRONTEND=none \
    APT_LISTBUGS_FRONTEND=none

# Set the shell options for safer script execution.
SHELL ["/bin/bash", "-o", "errexit", "-o", "errtrace", "-o", "functrace", "-o", "nounset", "-o", "pipefail", "-c"]

# Ensure the build process uses the root user.
USER root

# Copy apt.conf and dpkg.cfg to their respective locations.
COPY config/apt.conf /etc/apt/apt.conf.d/99custom-apt.conf
COPY config/dpkg.cfg /etc/dpkg/dpkg.cfg.d/99custom-dpkg.cfg

# Copy the package list to the container
COPY package.list /tmp/package.list

# Run apt-config dump to log the current configuration
RUN apt-config dump > /var/log/apt-config.log

# Optional: Display the log file (for CI/CD or debugging purposes)
RUN cat /var/log/apt-config.log

# Install the packages listed in package.list, ignoring comments and empty lines
RUN apt-get update && \
    apt-get install $(grep --invert-match --extended-regexp '^\s*(#|$)' /tmp/package.list) && \
    rm -rf /var/lib/apt/lists/*

# Install the required package for locale settings
RUN apt-get update && apt-get install -y locales \
    && echo "${LANG} UTF-8" > /etc/locale.gen \
    && locale-gen "${LANG}"

# Set the locale using the environment variables
RUN update-locale LANG=${LANG} LANGUAGE=${LANGUAGE} LC_ALL=${LC_ALL}

# Create a non-root user with specific configurations.
RUN groupadd \
    --gid ${SANCTUARY_GID} ${SANCTUARY_GROUP} \
    && useradd \
    --no-log-init \
    --create-home \
    --uid ${SANCTUARY_UID} \
    --gid ${SANCTUARY_GID} \
    --comment "Non-root User for Running Applications" \
    --home /home/${SANCTUARY_USER} \
    --skel /etc/skel \
    --shell /sbin/nologin \
    ${SANCTUARY_USER}

ENTRYPOINT [ "tail", "-f", "/dev/null" ]
