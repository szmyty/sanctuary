#!/usr/bin/env bash

# @Project: sanctuary
# @File: set_timezone.sh
# @Description: Script to set the timezone on a Debian-based system with error handling.
# @Author: Alan Szmyt
# @Date: 2024-08-30

# Function to check if a package is installed
is_package_installed() {
    local _package="$1"

    local _package_status
    _package_status=$(dpkg-query --show --showformat='${Status}\n' "${_package}" 2>/dev/null)

    # Check if the package is installed
    if echo "${_package_status}" | grep -q "install ok installed"; then
        echo "Package '${_package}' is already installed."
        return 0
    else
        echo "Package '${_package}' is not installed."
        return 1
    fi
}

apt-get update

if is_package_installed "tzdata"; then
    echo "Proceeding since the package is installed."
else
    echo "Installing the package..."
    sudo apt-get install --yes tzdata
fi

# Set the default timezone if TZ is not set
timezone="${TZ:-UTC}"

# Function to check if a timezone is valid
is_valid_timezone() {
    if [[ -f "/usr/share/zoneinfo/$1" ]]; then
        return 0
    else
        return 1
    fi
}

# Check if the timezone is valid
if ! is_valid_timezone "${timezone}"; then
    echo "Invalid timezone: ${timezone}" >&2
    exit 1
fi

# Commit change: Update the timezone
echo "Setting timezone to ${timezone}."

# Create a symbolic link to the appropriate timezone file
ln -sf "/usr/share/zoneinfo/${timezone}" /etc/localtime

# Update /etc/timezone
echo "${timezone}" > /etc/timezone

# Reconfigure tzdata to apply changes
dpkg-reconfigure -f noninteractive tzdata

# Final confirmation
echo "Timezone has been set to ${timezone}."
echo "You may want to restart any long-running services or daemons to apply the new timezone settings."
