# syntax=docker/dockerfile:1

######################################################################
# @Project      : sanctuary
# @File         : Dockerfile
# @Description  : Multi-stage Dockerfile for building TileDB and its Python bindings.
#
# This Dockerfile is designed to build a secure and efficient container
# with TileDB and TileDB-Py installed. It breaks down the build process
# into multiple stages for better organization and smaller final image size.
#
# @Author       : Alan Szmyt
# @Date         : 2024-08-23
# @Version      : 1.0
# @References   :
#   - https://github.com/TileDB-Inc/TileDB-Docker/blob/master/release/Dockerfile
#   - https://github.com/TileDB-Inc/TileDB-Docker/blob/master/base/Dockerfile
#   - https://github.com/TileDB-Inc/TileDB/releases/tag/2.25.0
#   - https://github.com/microsoft/vcpkg/blob/master/scripts/bootstrap.sh
#   - https://github.com/GeorgeErickson/TileDB/blob/dev/doc/source/installation.rst
######################################################################

######################################################################
# Stage 1: Base Setup
# This stage sets up the base environment with necessary packages and dependencies.
######################################################################
# Project name.
ARG PROJECT_NAME=sanctuary

# Image name to use.
ARG BASE_IMAGE_NAME=base

# Image version to use.
ARG BASE_IMAGE_VERSION=latest

ARG TILEDB_PORT=6379
ARG TILEDB_DATA_DIR=

# Use a base image.
FROM ${PROJECT_NAME}/${BASE_IMAGE_NAME}:${BASE_IMAGE_VERSION} AS base

LABEL stage="base"
LABEL description="Base stage with necessary dependencies for building TileDB."
# Switch to root user to install required dependencies.
USER root

# Install required dependencies for the build.
RUN apt-get update && apt-get install --yes \
    build-essential \
    cmake \
    git \
    wget \
    ninja-build \
    python3-pip \
    libsnappy-dev \
    libblosc-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    libjemalloc-dev \
    libtbb-dev \
    libtiff-dev \
    libz-dev \
    libboost-all-dev \
    clang-format \
    clang-tidy \
    && rm -rf /var/lib/apt/lists/*

######################################################################
# Stage 2: Build TileDB
# This stage clones the TileDB repository and builds it.
######################################################################
FROM base AS build-tiledb

LABEL stage="build-tiledb"
LABEL description="Stage to build TileDB from source."

ARG TILEDB_VER_MAJOR=2
ARG TILEDB_VER_MINOR=25
ARG TILEDB_VER_PATCH=0
ARG TILEDB_REPO_URL="https://github.com/TileDB-Inc/TileDB.git"

ENV TILEDB_VERSION="${TILEDB_VER_MAJOR}.${TILEDB_VER_MINOR}.${TILEDB_VER_PATCH}"

WORKDIR /tmp/tiledb

# Clone the TileDB repository and configure the build.
RUN git clone --quiet --depth 1 --shallow-submodules --recurse-submodules --branch ${TILEDB_VERSION} ${TILEDB_REPO_URL} . \
    && mkdir build \
    && cd build \
    && cmake .. \
    -GNinja \
    -DCOMPILER_SUPPORTS_AVX2=FALSE \
    -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_INSTALL_PREFIX="/usr/local" \
    -DTILEDB_REMOVE_DEPRECATIONS="OFF" \
    -DTILEDB_VERBOSE="ON" \
    -DTILEDB_S3="ON" \
    -DTILEDB_AZURE="OFF" \
    -DTILEDB_GCS="OFF" \
    -DTILEDB_HDFS="OFF" \
    -DTILEDB_WERROR="OFF" \
    -DCMAKE_C_COMPILER="/usr/bin/gcc" \
    -DCMAKE_CXX_COMPILER="/usr/bin/g++" \
    -DTILEDB_ASSERTIONS="OFF" \
    -DTILEDB_CPP_API="ON" \
    -DTILEDB_STATS="ON" \
    -DBUILD_SHARED_LIBS="ON" \
    -DTILEDB_TESTS="ON" \
    -DTILEDB_TOOLS="ON" \
    -DTILEDB_SERIALIZATION="ON" \
    -DTILEDB_CCACHE="ON" \
    -DTILEDB_ARROW_TESTS="OFF" \
    -DTILEDB_WEBP="ON" \
    -DTILEDB_EXPERIMENTAL_FEATURES="OFF" \
    -DTILEDB_TESTS_AWS_S3_CONFIG="OFF" \
    -DTILEDB_DISABLE_AUTO_VCPKG="OFF" \
    && ninja --verbose -j1 all \
    && ninja --verbose -j1 install-tiledb

######################################################################
# Stage 3: Build TileDB-Py
# This stage clones the TileDB-Py repository and installs the Python bindings.
######################################################################
FROM base AS build-tiledb-py

LABEL stage="build-tiledb-py"
LABEL description="Stage to build and install TileDB-Py with a virtual environment."

ARG TILEDB_PY_VER_MAJOR=0
ARG TILEDB_PY_VER_MINOR=31
ARG TILEDB_PY_VER_PATCH=1
ARG TILEDB_PY_REPO_URL="https://github.com/TileDB-Inc/TileDB-Py.git"

ENV TILEDB_PY_VERSION="${TILEDB_PY_VER_MAJOR}.${TILEDB_PY_VER_MINOR}.${TILEDB_PY_VER_PATCH}"
ENV VIRTUAL_ENV="/opt/venv"
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

WORKDIR /tmp/tiledb-py

# Install Python3 venv package, clone the TileDB-Py repository, and install the Python bindings in a virtual environment.
RUN apt-get update && apt-get install --yes python3-venv \
    && python3 -m venv ${VIRTUAL_ENV} \
    && git clone --quiet --recurse-submodules --branch ${TILEDB_PY_VERSION} ${TILEDB_PY_REPO_URL} .
#     && pip install --upgrade pip \
#     && pip install --requirement requirements.txt \
#     && python setup.py install --tiledb=/usr/local

# # Clean up APT when done.
# RUN apt-get remove -y python3-venv && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

######################################################################
# Stage 4: Final Image
# This stage copies the necessary files from the build stages and prepares the final image.
######################################################################
# FROM base AS final
FROM  build-tiledb-py as final

LABEL stage="final"
LABEL description="Final stage with TileDB and TileDB-Py installed."

# Copy TileDB and TileDB-Py installations from the build stages.
# COPY --from=build-tiledb /usr/local /usr/local
# COPY --from=build-tiledb-py /usr/local /usr/local

# Set the environment variable to ensure the correct libraries are found.
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

# Set working directory.
WORKDIR /workspace

# RUN ${SANCTUARY_BIN}/post-install.sh

# Need to switch to a non-root user to avoid running as root.

# Default command (override as needed).
CMD ["/bin/bash"]
