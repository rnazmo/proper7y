#!/usr/bin/env bash
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
  "${PROJECT_ROOT}/proper7y"
  "${PROJECT_ROOT}/install.sh"
  "${COMMON_SH_PATH}"
  "${DEVEL_TOOLS_DIR}/script/run-lint.linux-x64.sh"
  "${DEVEL_TOOLS_DIR}/script/run-format.linux-x64.sh"
  "${DEVEL_TOOLS_DIR}/script/run-integ-test.linux-x64.sh"
  "${DEVEL_TOOLS_DIR}/script/bump-project.linux-x64.sh"
  "${DEVEL_TOOLS_DIR}/script/install-devel-tools.linux-x64.sh"
  "${DEVEL_TOOLS_DIR}/script/check-devel-tools-versions.linux-x64.sh"
)

main() {
  log_info "Start running format..."

  log_warn "This script OVERWRITE the target files."
  log_warn "Recommend you to save it before running."
  confirm_continue

  # 1. Check if the tools are installed
  check_shfmt_is_ready

  # 2. Run format
  for TARGET in "${TARGETS[@]}"; do
    log_info "TARGET: $TARGET"
    log_info "  Running format to the target: START"

    "$SHFMT_CMD_PATH" -i 2 -w "$TARGET"

    log_info "  Running format to the target: END"
  done

  log_info "Ran all format successflly!"
}

main
