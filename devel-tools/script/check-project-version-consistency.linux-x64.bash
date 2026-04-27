#!/usr/bin/env bash
set -euo pipefail

# TL;DR (What is this?):
#   Verify that the variable PROPER7Y_VERSION is consistent across
#   all files that define it: proper7y, install.bash, and common.bash.

source "$(dirname "$0")/common.bash"
initialize_global_variables

main() {
  log_info "Start checking project version consistency..."

  verify_version_consistency "$PROPER7Y_VERSION"

  log_info "Checked. All versions are consistent!"
}

main

exit 0
