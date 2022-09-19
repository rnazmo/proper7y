#!/bin/bash
set -eu

# TL:DR (What is this?)
#   - Run '/devel-tools/bin/shellcheck' to the TARGETS.
#   - Run '/devel-tools/bin/shfmt' to the TARGETS with the option "-i 2 -d"
#   (See below the variable 'TARGETS' to know what files are included in it.)

source "$(dirname "$0")/common.sh"

# Targets of runnning lint.
TARGETS=(
  "${PROJECT_ROOT}/property"
  "${PROJECT_ROOT}/install.sh"
  "${PROJECT_ROOT}/devel-tools/script/common.sh"
  "${PROJECT_ROOT}/devel-tools/script/run-lint.linux-x64.sh"
  "${PROJECT_ROOT}/devel-tools/script/run-format.linux-x64.sh"
  "${PROJECT_ROOT}/devel-tools/script/run-integ-test.linux-x64.sh"
  "${PROJECT_ROOT}/devel-tools/script/bump-project.linux-x64.sh"
  "${PROJECT_ROOT}/devel-tools/script/install-devel-tools.linux-x64.sh"
  "${PROJECT_ROOT}/devel-tools/script/check-devel-tools-versions.linux-x64.sh"
)

main() {
  log_info "Start running lint..."

  # 1. Check if the tools are installed
  check_shellcheck_is_ready
  check_shfmt_is_ready

  # 2. Run lint
  for TARGET in "${TARGETS[@]}"; do
    log_info "Running lint to the target: START"
    log_info "TARGET: $TARGET"

    "$SHELLCHECK_CMD_PATH" --exclude SC1091 "$TARGET"
    "$SHFMT_CMD_PATH" -i 2 -d "$TARGET"

    log_info "Running lint to the target: END"
  done

  log_info "Ran all lint successflly!"
}

main
