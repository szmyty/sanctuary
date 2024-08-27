#!/usr/bin/env bash
set -euo pipefail

# Source the environment variables
source "$(dirname "${BASH_SOURCE[0]}")/.environment"

# Function to ensure the necessary directories exist
ensure_directories() {
  echo "Ensuring directories exist..."
  mkdir -p "${SANCTUARY_PNPM_INSTALL_DIR:-}"
  mkdir -p "${SANCTUARY_BIN_DIR:-}"
  echo "Directories ensured."
}

# Function to get pnpm version
get_pnpm_version() {
  if command -v pnpm >/dev/null 2>&1; then
    pnpm --version
  fi
}

# Function to get asdf version
get_asdf_version() {
  if command -v asdf >/dev/null 2>&1; then
    asdf --version
  fi
}

# Function to get ShellCheck version
get_shellcheck_version() {
  if [ -x "${SANCTUARY_BIN_DIR}/shellcheck" ]; then
    "${SANCTUARY_BIN_DIR}/shellcheck" --version | grep -Eo 'version: [0-9]+\.[0-9]+\.[0-9]+' | cut -d' ' -f2
  fi
}

# Function to install pnpm
install_pnpm() {
  if command -v pnpm >/dev/null 2>&1; then
    echo "pnpm is already installed."
    SANCTUARY_PNPM_VERSION="$(get_pnpm_version)"
    export SANCTUARY_PNPM_VERSION
    return
  fi

  echo "Installing pnpm..."

  # Temporarily set SHELL to bash to avoid errors during installation
  export SHELL="/bin/bash"

  # Install pnpm using the official script
  curl --fail --silent --location "${GITHUB_URL_PNPM_INSTALL_SCRIPT}" | bash -

  echo "pnpm installed in ${SANCTUARY_PNPM_INSTALL_DIR:-}"
  SANCTUARY_PNPM_VERSION="$(get_pnpm_version)"
  export SANCTUARY_PNPM_VERSION

  # Restore SHELL to custom shell after installation
  export SHELL="${SANCTUARY_ROOT}/.shell"
}

# Function to install asdf
install_asdf() {
  if [ -d "${SANCTUARY_ASDF_HOME}" ]; then
    echo "asdf is already installed."
    SANCTUARY_ASDF_VERSION="$(get_asdf_version)"
    export SANCTUARY_ASDF_VERSION
    return
  fi

  echo "Installing asdf..."

  # Clone the asdf repository into the local devtools directory
  git clone "${GITHUB_URL_ASDF_REPO}" "${SANCTUARY_ASDF_HOME}"

  # Create a symlink for asdf in the bin directory
  ln -sf "${SANCTUARY_ASDF_HOME}/bin/asdf" "${SANCTUARY_BIN_DIR}/asdf"

  # Set up asdf environment
  . "${SANCTUARY_ASDF_HOME}/asdf.sh"

  echo "asdf installed and symlinked to ${SANCTUARY_BIN_DIR}"
  SANCTUARY_ASDF_VERSION="$(get_asdf_version)"
  export SANCTUARY_ASDF_VERSION
}

# Function to install ShellCheck using asdf
install_shellcheck() {
  if [ -x "${SANCTUARY_BIN_DIR}/shellcheck" ]; then
    echo "ShellCheck is already installed."
    SANCTUARY_SHELLCHECK_VERSION="$(get_shellcheck_version)"
    export SANCTUARY_SHELLCHECK_VERSION
    return
  fi

  echo "Installing ShellCheck using asdf..."

  # Add the ShellCheck plugin
  asdf plugin add shellcheck "${ASDF_PLUGIN_URL_SHELLCHECK}"

  # Install ShellCheck version from .tool-versions file
  asdf install shellcheck

  # Create a symlink for ShellCheck in the bin directory
  local _shellcheck_path
  _shellcheck_path="$(asdf which shellcheck)"
  ln -sf "${_shellcheck_path}" "${SANCTUARY_BIN_DIR}/shellcheck"

  echo "ShellCheck installed via asdf and symlinked to ${SANCTUARY_BIN_DIR}"
  SANCTUARY_SHELLCHECK_VERSION="$(get_shellcheck_version)"
  export SANCTUARY_SHELLCHECK_VERSION
}

# Ensure directories are created
ensure_directories

# Call the installation functions
# install_pnpm
install_asdf
install_shellcheck

# Future installation commands (e.g., Python, Node.js) can be added here
