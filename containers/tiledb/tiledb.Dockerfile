# syntax=docker/dockerfile:1

######################################################################
# @Project      : sanctuary
# @File         : Dockerfile
# @Description  : Dockerfile for building a secure and efficient container.
#
#
#
# @Author       : Alan Szmyt
# @Date         : 2024-08-23
# @Version      : 1.0
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
FROM ${PROJECT_NAME}/${BASE_IMAGE_NAME}:${BASE_IMAGE_VERSION}

ENV AWS_EC2_METADATA_DISABLED=true
ARG TILEDB_VER_MAJOR
ENV TILEDB_VER_MAJOR=${TILEDB_VER_MAJOR:-2}
ARG TILEDB_VER_MINOR
ENV TILEDB_VER_MINOR=${TILEDB_VER_MINOR:-25}
ARG TILEDB_VER_PATCH
ENV TILEDB_VER_PATCH=${TILEDB_VER_PATCH:-0}

ENV TILEDB_VER="${TILEDB_VER_MAJOR}.${TILEDB_VER_MINOR}"
ENV TILEDB_VERSION="${TILEDB_VER}.${TILEDB_VER_PATCH}"
ENV TILEDB_REPO_URL="https://github.com/TileDB-Inc/TileDB.git"

# Optional components to enable (defaults to empty).
ARG enable=

# Ensure the build process uses the root user.
USER root

# ARG AWS_SDK_CPP_VER_MAJOR
# ENV AWS_SDK_CPP_VER_MAJOR ${AWS_SDK_CPP_VER_MAJOR:-1}
# ARG AWS_SDK_CPP_VER_MINOR
# ENV AWS_SDK_CPP_VER_MINOR ${AWS_SDK_CPP_VER_MINOR:-11}
# ARG AWS_SDK_CPP_VER_PATCH
# ENV AWS_SDK_CPP_VER_PATCH ${AWS_SDK_CPP_VER_PATCH:-394}

# ENV AWS_SDK_CPP_VER "${AWS_SDK_CPP_VER_MAJOR}.${AWS_SDK_CPP_VER_MINOR}"
# ENV AWS_SDK_CPP_VERSION "${AWS_SDK_CPP_VER}.${AWS_SDK_CPP_VER_PATCH}"

# # Build the AWS SDK C++.
# RUN git clone --depth 1 --shallow-submodules --recurse-submodules --branch ${AWS_SDK_CPP_VERSION} \
#     https://github.com/aws/aws-sdk-cpp.git /tmp/aws-sdk-cpp/ && \
#     mkdir -p /tmp/aws-sdk-cpp/build && \
#     cd /tmp/aws-sdk-cpp/build && \
#     CXX=clang++ CC=clang \
#     cmake \
#     -DBUILD_ONLY="s3" \
#     -DCMAKE_BUILD_TYPE=Release \
#     -DCPP_STANDARD=17 \
#     -DENABLE_TESTING=OFF \
#     -DCUSTOM_MEMORY_MANAGEMENT=OFF \
#     -DCMAKE_INSTALL_PREFIX=/opt/aws-sdk-cpp-${AWS_SDK_CPP_VER}/ \
#     .. && \
#     cmake --build . --config=Release && \
#     cmake --install . --config=Release && \
#     rm -rf /tmp/aws-sdk-cpp



# Install TileDB
# RUN wget -P /home/tiledb https://github.com/TileDB-Inc/TileDB/archive/${version}.tar.gz \
#     && tar xzf /home/tiledb/${version}.tar.gz -C /home/tiledb \
#     && rm /home/tiledb/${version}.tar.gz \
#     && cd /home/tiledb/TileDB-${version} \
#     && mkdir build \
#     && cd build \
#     && ../bootstrap --prefix=/usr/local --enable-azure --enable-s3 --enable-serialization --enable=${enable} \
#     && make -j$(nproc) \
#     && make -j$(nproc) examples \
#     && make install-tiledb \
#     && rm -rf /home/tiledb/TileDB-${version}

# RUN git clone https://github.com/Microsoft/vcpkg.git ${TMPDIR}/vcpkg \
#     && cd ${TMPDIR}/vcpkg \
#     && ./bootstrap-vcpkg.sh \
#     && ./vcpkg install aws-sdk-cpp[core,s3] \
#     && rm -rf ${TMPDIR}/vcpkg
# WORKDIR /home/vcpkg
# RUN ./bootstrap-vcpkg.sh

# Build TileDB.
# RUN git config --global advice.detachedHead false \
#     && git clone \
#     --quiet \
#     --depth 1 \
#     --shallow-submodules \
#     --recurse-submodules \
#     --branch ${TILEDB_VERSION} \
#     ${TILEDB_REPO_URL} ${TMPDIR}/tiledb/ \
#     && cd ${TMPDIR}/tiledb \
#     && mkdir build \
#     && cd build \
# && CXX=clang++ CC=clang \
# && CMAKE_MAKE_PROGRAM=$(which make) \
# && CMAKE_GENERATOR="Unix Makefiles" \
# && ../bootstrap \
# --prefix=/usr/local \
# --enable-s3 \
# --enable-serialization \
# && make ${BUILD_CORES:-$(nproc)} \
# && make install-tiledb \
# && rm -rf ${TMPDIR}/tiledb

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential make cmake git libssl-dev libbz2-dev liblz4-dev libzstd-dev \
    libsnappy-dev libblosc-dev liblzma-dev libcurl4-openssl-dev \
    libjemalloc-dev libtbb-dev libtbb-dev libtiff-dev \
    libz-dev libboost-all-dev ca-certificates clang-format clang-tidy && \
    rm -rf /var/lib/apt/lists/*

# RUN git config --global advice.detachedHead false \
#     && git clone \
#     --quiet \
#     --depth 1 \
#     --shallow-submodules \
#     --recurse-submodules \
#     --branch ${TILEDB_VERSION} \
#     ${TILEDB_REPO_URL} ${TMPDIR}/tiledb/ \
#     && cd ${TMPDIR}/tiledb \
#     && mkdir build \
#     && cd build \
#     && cmake .. -DCMAKE_BUILD_TYPE="Release" \
#     -DCMAKE_INSTALL_PREFIX="/usr/local" \
#     -DCMAKE_C_COMPILER="/usr/bin/gcc" \
#     -DCMAKE_CXX_COMPILER="/usr/bin/g++" \
#     -DTILEDB_VERBOSE="ON" \
#     -DTILEDB_HDFS="OFF" \
#     -DTILEDB_S3="ON" \
#     -DTILEDB_AZURE="OFF" \
#     -DTILEDB_GCS="OFF" \
#     -DTILEDB_SERIALIZATION="ON" \
#     -DTILEDB_TOOLS="OFF" \
#     -DTILEDB_WERROR="ON" \
#     -DTILEDB_CPP_API="ON" \
#     -DTILEDB_STATS="ON" \
#     -DTILEDB_STATIC="OFF" \
#     -DTILEDB_TESTS="ON" \
#     -DTILEDB_CCACHE="OFF" \
#     -DTILEDB_ARROW_TESTS="OFF" \
#     -DTILEDB_FORCE_ALL_DEPS="OFF" && \
#     make --jobs=$(nproc) && \
#     make install

ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"
