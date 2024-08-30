#!/usr/bin/env bash
#
# @Project: sanctuary
# @File: setup_locale.sh
# @Description: Script to configure the locale for Debian Bookworm and check for necessary package installations.
# @Author: Alan Szmyt
# @Date: 2024-08-30
#
# This script checks if a specified package is installed on a Debian-based system using dpkg-query.
# If the package is not installed, the script will install it.
#
# Usage:
# ./setup_locale.sh
#
# References:
# https://www.gnu.org/software/gettext/manual/gettext.html#Locale-Environment-Variables
# https://wiki.debian.org/ChangeLanguage

set -exuo pipefail

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

if is_package_installed "locales"; then
    echo "Proceeding since the package is installed."
else
    echo "Installing the package..."
    apt-get install --yes locales
fi

if is_package_installed "locales-all"; then
    echo "Proceeding since the package is installed."
else
    echo "Installing the package..."
    apt-get install --yes locales-all
fi

echo "Configuring the locale..."

# Determine the locale based on the priority: LANGUAGE > LC_ALL > LANG
_locale="${LANG:-en_US.UTF-8}"
_language="${LANGUAGE:-en_US:en}"
_lc_ctype="${LC_CTYPE:-${_locale}}"
_lc_numeric="${LC_NUMERIC:-${_locale}}"
_lc_time="${LC_TIME:-${_locale}}"
_lc_collate="${LC_COLLATE:-${_locale}}"
_lc_monetary="${LC_MONETARY:-${_locale}}"
_lc_messages="${LC_MESSAGES:-${_locale}}"
_lc_paper="${LC_PAPER:-${_locale}}"
_lc_name="${LC_NAME:-${_locale}}"
_lc_address="${LC_ADDRESS:-${_locale}}"
_lc_telephone="${LC_TELEPHONE:-${_locale}}"
_lc_measurement="${LC_MEASUREMENT:-${_locale}}"
_lc_identification="${LC_IDENTIFICATION:-${_locale}}"

echo "The selected locale is: ${_locale}"

# Uncomment the desired locale in /etc/locale.gen
echo "Uncommenting the locale in /etc/locale.gen..."
sed -i "/^# *${_locale}/s/^# *//" /etc/locale.gen

echo "Generating locale..."
locale-gen "${_locale}"

update-locale \
    LANG="${_locale}" \
    LANGUAGE="${_language}" \
    LC_CTYPE="${_lc_ctype}" \
    LC_NUMERIC="${_lc_numeric}" \
    LC_TIME="${_lc_time}" \
    LC_COLLATE="${_lc_collate}" \
    LC_MONETARY="${_lc_monetary}" \
    LC_MESSAGES="${_lc_messages}" \
    LC_PAPER="${_lc_paper}" \
    LC_NAME="${_lc_name}" \
    LC_ADDRESS="${_lc_address}" \
    LC_TELEPHONE="${_lc_telephone}" \
    LC_MEASUREMENT="${_lc_measurement}" \
    LC_IDENTIFICATION="${_lc_identification}"

dpkg-reconfigure --frontend=noninteractive locales

echo "Locale configuration completed."

exit 0
