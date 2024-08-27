#!/usr/bin/env bash
set -euo pipefail

# Source the environment variables.
source "$(dirname "${BASH_SOURCE[0]}")/.environment"

printenv | sort

#pnpm commitlint --from=HEAD~1 --to=HEAD
