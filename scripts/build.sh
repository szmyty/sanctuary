#!/usr/bin/env bash

# The script expects the project name as the first argument.
if [[ -z "${1}" ]]; then
    echo "Usage: $0 <project-name>"
    exit 1
fi

# Save the project name in an environment variable.
export PROJECT_NAME="${1}"

# The project root is the directory where the script is executed.
if [[ -z "${PROJECT_ROOT}" ]]; then
    PROJECT_ROOT="$(pwd)"
    export PROJECT_ROOT
fi

echo "Building project ${PROJECT_NAME} in ${PROJECT_ROOT}"

export LATEXMKRC_FILE="${PROJECT_ROOT}/.latexmkrc"
export TEX_PROJECT_ROOT="${PROJECT_ROOT}/${1}"
export MAIN_TEX_FILE="${TEX_PROJECT_ROOT}/main.tex"

if [[ ! -d "${TEX_PROJECT_ROOT}" ]]; then
    echo "Project directory not found: ${TEX_PROJECT_ROOT}"
    exit 1
fi

if [[ ! -f "${LATEXMKRC_FILE}" ]]; then
    echo "LaTeXmk configuration file not found: ${LATEXMKRC_FILE}"
    exit 1
fi

if [[ ! -f "${MAIN_TEX_FILE}" ]]; then
    echo "Main TeX file not found: ${MAIN_TEX_FILE}"
    exit 1
fi

latexmk -pdf -r "${PROJECT_ROOT}/.latexmkrc" "${MAIN_TEX_FILE}"

# Check if latexmk was successful.
if [[ $? -eq 0 ]]; then
    echo "LaTeX build successful."
else
    echo "LaTeX build failed."
    exit 1
fi
