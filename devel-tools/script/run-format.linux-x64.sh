#!/bin/bash
set -eu

# TL:DR (What is this?)
#   - Run '/devel-tools/bin/shfmt' to the TARGETS with the option " -i 2 -w"
#   (See below the variable 'TARGETS' to know what files are included in it.)
#
# NOTE
#   - This script OVERWRITE the target files. Recommend you to save it before running.

source "$(dirname "$0")/common.sh"

# Targets of runnning format.
TARGETS=(
  "${PROJECT_ROOT}/property"
  "${PROJECT_ROOT}/install.sh"
  "${PROJECT_ROOT}/devel-tools/script/install-dependencies-for-devel.linux-x64.sh"
  "${PROJECT_ROOT}/devel-tools/script/run-lint.linux-x64.sh"
  "${PROJECT_ROOT}/devel-tools/script/run-format.linux-x64.sh"
  "${PROJECT_ROOT}/devel-tools/script/common.sh"
)

main() {
  echo "INFO : Start running format..."

  echo "WARN: This script OVERWRITE the target files."
  echo "      Recommend you to save it before running."
  confirm_continue

  # 1. Check if the tools are installed
  check_if_shfmt_exists
  print_shfmt_version

  # 2. Run format
  for TARGET in "${TARGETS[@]}"; do
    echo "INFO: Running format to the target: START"
    echo "INFO: TARGET: $TARGET"

    "$SHFMT_CMD_PATH" -i 2 -w "$TARGET"

    echo "INFO: Running format to the target: END"
  done

  echo "INFO : Ran all format successflly!"
}

main
