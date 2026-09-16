#!/usr/bin/env bash
# Nix's clang-tidy wrapper uses Bash to add the development shell's include flags.
set -euo pipefail
exec bash "$(command -v clang-tidy)" "$@"
