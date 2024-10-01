#!/usr/bin/env bash

# Check if an argument is provided
if [[ -z "${1}" ]]; then
    echo "Usage: $0 <path_to_article_directory>"
    exit 1
fi

# full path to the TeX root (the directory containing the article)
TEX_ROOT="$(realpath "${1}")"

# Extract the project name (the last component of the path)
PROJECT_NAME="$(basename "${TEX_ROOT}")"

# Export the project name
export PROJECT_NAME
export TEX_ROOT

# Now you can use $TEX_ROOT and $PROJECT_NAME in your script
echo "TeX root directory: ${TEX_ROOT}"
echo "Project name: ${PROJECT_NAME}"

# The project root is the directory where the script is executed.
if [[ -z "${PROJECT_ROOT}" ]]; then
    PROJECT_ROOT="$(pwd)"
    export PROJECT_ROOT
fi

echo "Building project ${PROJECT_NAME} in ${PROJECT_ROOT}"

export LATEXMKRC_FILE="${PROJECT_ROOT}/.latexmkrc"
export TEX_PROJECT_ROOT="${TEX_ROOT}"
export MAIN_TEX_FILE_NAME="main"
export MAIN_TEX_FILE="${TEX_PROJECT_ROOT}/${MAIN_TEX_FILE_NAME}.tex"
export PROJECT_CACHE_DIR="${PROJECT_ROOT}/.cache/latex";

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

latexmk \
    "${MAIN_TEX_FILE}" \
    -deps-out="${PROJECT_CACHE_DIR}/${PROJECT_NAME}.deps" \
    -recorder \
    -verbose

# Check if latexmk was successful.
if [[ $? -eq 0 ]]; then
    echo "LaTeX build successful."
else
    echo "LaTeX build failed."
    exit 1
fi
