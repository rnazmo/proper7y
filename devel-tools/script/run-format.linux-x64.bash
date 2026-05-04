#!/usr/bin/env bash
set -euo pipefail

# TL:DR (What is this?)
#   - Run '/devel-tools/bin/shfmt' to the TARGETS with the option " -i 2 -w"
#   (See below the variable 'TARGETS' to know what files are included in it.)
#
# NOTE
#   - This script OVERWRITE the target files. Recommend you to save it before running.

source "$(dirname "$0")/common.bash"
initialize_global_variables

# Targets of runnning format.
TARGETS=(
  "${PROJECT_ROOT}/proper7y"
  "${PROJECT_ROOT}/install.bash"
  "${COMMON_SH_PATH}"
  "${DEVEL_TOOLS_DIR}/script/run-lint.linux-x64.bash"
  "${DEVEL_TOOLS_DIR}/script/run-format.linux-x64.bash"
  "${DEVEL_TOOLS_DIR}/script/run-integ-test.bash"
  "${DEVEL_TOOLS_DIR}/script/bump-project.linux-x64.bash"
  "${DEVEL_TOOLS_DIR}/script/install-devel-tools.linux-x64.bash"
  "${DEVEL_TOOLS_DIR}/script/check-devel-tools-versions.linux-x64.bash"
  "${DEVEL_TOOLS_DIR}/script/check-project-version-consistency.linux-x64.bash"
  "${PROJECT_ROOT}/test/unit/is_supported.bats"
  "${PROJECT_ROOT}/test/unit/string_format.bats"
  "${PROJECT_ROOT}/test/unit/print_chassis.bats"
  "${PROJECT_ROOT}/test/unit/print_kernel_version.bats"
  "${PROJECT_ROOT}/test/unit/print_field_mapping.bats"
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

  log_info "Ran all format successfully!"
}

main

exit 0
