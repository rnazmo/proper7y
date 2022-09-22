#!/bin/bash
set -eu

# TL:DR (What is this?)
#   Install shellcheck and shfmt binary under 'foo/property/devel-tools/bin/'.

source "$(dirname "$0")/common.sh"

main() {
  log_info "Start installing..."

  # 1. Check if the DEVEL_TOOLS_BIN_DIR exists
  check_if_devel_tools_bin_dir_exists

  # 2. Install shellcheck
  install_shellcheck
  check_shellcheck_is_ready

  # 3. Install shfmt
  install_shfmt
  check_shfmt_is_ready

  log_info "Installed successflly!"
}

main
