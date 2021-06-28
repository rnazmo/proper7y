#!/bin/bash
set -eu

# TL;DR (What is this?):
#   - Install and run stable 'property'.

source "$(dirname "$0")/common.sh"

URL="https://raw.githubusercontent.com/rnazmo/property/main/install.sh"

main() {
  log_info "Start running integ-test (Install and run stable 'property')"

  log_info "Cd to temp directory"
  cd "$(mktemp -d)"
  log_info "pwd: $(pwd)"

  log_info "Get the 'install.sh'"
  curl -O "$URL"
  chmod +x ./install.sh

  log_info "Run the 'install.sh' and install property"
  ./install.sh .

  log_info "Run property"
  ./property

  log_info "Running integ-test successflly!"
}

main
