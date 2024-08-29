#!/usr/bin/env bash

packages=$(dpkg-query --show --showformat='${Package}=${Version}\n')

echo "${packages}" | sort
