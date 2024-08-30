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
    TMPDIR=/tmp

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
COPY config/apt.conf /etc/apt/apt.conf.d/99custom-apt.conf
COPY config/dpkg.cfg /etc/dpkg/dpkg.cfg.d/99custom-dpkg.cfg

# Copy the package list to the container.
COPY package.list /${TMPDIR}/package.list

# Log the current APT configuration.
RUN apt-config dump > /var/log/apt-config.log

# Optional: Display the log file (for CI/CD or debugging purposes).
RUN cat /var/log/apt-config.log

# Install the packages listed in package.list, ignoring comments and empty lines.
# RUN /bin/bash -c "${SANCTUARY_BIN}/tools/apt_install_package_list.sh /tmp/package.list"
# RUN apt-get update \
#     && apt-get install -y \
#     ca-certificates \
#     gosu \
#     pwgen \
#     tzdata \
#     gcc \
#     gcc-multilib \
#     g++ \
# build-essential \
# bison \
# chrpath \
# make \
# cmake \
# gdb \
# lz4 \
# zstd \
# zip \
# gnutls-dev \
# libaio-dev \
# libboost-dev \
# libdbd-mysql \
# libjudy-dev \
# libncurses5-dev \
# libpam0g-dev \
# libpcre3-dev \
# libreadline-dev \
# libstemmer-dev \
# libssl-dev \
# libnuma-dev \
# libxml2-dev \
# lsb-release \
# perl \
# psmisc \
# zlib1g-dev \
# libcrack2-dev \
# cracklib-runtime \
# libjemalloc-dev \
# libsnappy-dev \
# liblzma-dev \
# libzmq3-dev \
# uuid-dev \
# ccache \
# git \
# wget \
# bzip2 \
# zlib \
# libcurl4-openssl-dev \
# && rm -rf /var/lib/apt/lists/*


# Stage 2: Building the Base Image
FROM dependencies as base

# Set locale settings.
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Uncomment if locale configuration is needed
RUN apt-get update && apt-get install -y locales \
    && echo "${LANG} UTF-8" > /etc/locale.gen \
    && locale-gen "${LANG}" && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=${LANG} LANGUAGE=${LANGUAGE} LC_ALL=${LC_ALL}

# Switch to the non-root user.
USER ${SANCTUARY_USER}:${SANCTUARY_GROUP}

# Set Bash as the entry point to keep the container running.
ENTRYPOINT [ "bash", "-c", "tail -f /dev/null" ]
