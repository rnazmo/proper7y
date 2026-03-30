#!/usr/bin/env bash
set -eu

# TL;DR (What is this?):
#   - Install and run stable 'proper7y'.

source "$(dirname "$0")/common.bash"
initialize_global_variables

readonly URL="https://raw.githubusercontent.com/rnazmo/proper7y/main/install.bash"

main() {
  log_info "Start running integ-test (Install and run stable 'proper7y')"

  log_info "Cd to temp directory"
  local -r TEMP_DIR="$(mktemp -d)"
  trap 'rm -rf "${TEMP_DIR:-}"' EXIT # cleanup
  cd "$TEMP_DIR"
  log_info "TEMP_DIR: $TEMP_DIR"
  log_info "pwd: $(pwd)"

  log_info "Get the 'install.bash'"
  curl -O "$URL"
  chmod +x ./install.bash

  log_info "Run the 'install.bash' and install proper7y"
  ./install.bash .

  log_info "Run proper7y"
  ./proper7y

  log_info "Running integ-test successfully!"
}

main
