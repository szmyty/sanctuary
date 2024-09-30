#!/usr/bin/env bash

# Ensure PROJECT_ROOT is set
if [ -z "${PROJECT_ROOT}" ]; then
    export PROJECT_ROOT="$(pwd)"
fi

# Compile the LaTeX document with metadata using latexmk
latexmk -pdf -r "${PROJECT_ROOT}/.latexmkrc" \
-outdir="${PROJECT_ROOT}/.cache/latex/out" \
-auxdir="${PROJECT_ROOT}/.cache/latex/aux" \
"${PROJECT_ROOT}/templates/medium-article.tex"

# Optional: Post-process or convert (e.g., to other formats)
# ./scripts/convert.sh
