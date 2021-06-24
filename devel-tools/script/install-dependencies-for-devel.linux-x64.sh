#!/bin/bash
set -eu

# TL:DR (What is this?)
#   Install shellcheck and shfmt binary under 'foo/property/devel-tools/bin/'.

source "$(dirname "$0")/common.sh"

SHELLCHECK_URL="https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK_VERSION}/shellcheck-${SHELLCHECK_VERSION}.linux.x86_64.tar.xz"
SHFMT_URL="https://github.com/mvdan/sh/releases/download/${SHFMT_VERSION}/shfmt_${SHFMT_VERSION}_linux_amd64"

main() {
  echo "INFO : Start installing..."

  # 1. Check if the DEVEL_TOOLS_DIR exists
  check_if_devel_tools_dir_exists

  # 2. Install shellcheck
  install_shellcheck
  check_shellcheck_is_ready

  # 3. Install shfmt
  install_shfmt
  check_shfmt_is_ready

  echo "INFO : Installed successflly!"
}

# Check if the DEVEL_TOOLS_DIR exists and is a directory.
check_if_devel_tools_dir_exists() {
  if [ -e "$DEVEL_TOOLS_DIR" ] && [ ! -d "$DEVEL_TOOLS_DIR" ]; then
    echo "ERROR: The path $DEVEL_TOOLS_DIR sould be a directory not a file."
    exit 1
  elif [ ! -d "$DEVEL_TOOLS_DIR" ]; then
    mkdir "$DEVEL_TOOLS_DIR"
  fi
}

# Install shellcheck via the GitHub Releases Page as the file 'SHELLCHECK_CMD_PATH'.
# Ref: https://github.com/koalaman/shellcheck#installing
install_shellcheck() {
  local TEMP_DIR
  TEMP_DIR="$(mktemp -d)"
  echo "INFO: TEMP_DIR: $TEMP_DIR"

  cd "$TEMP_DIR"
  echo "INFO: PWD: $(pwd)"

  curl -OL "$SHELLCHECK_URL"
  tar -xf "./shellcheck-${SHELLCHECK_VERSION}.linux.x86_64.tar.xz"
  mv -f "./shellcheck-${SHELLCHECK_VERSION}/shellcheck" "$SHELLCHECK_CMD_PATH"

  rm -rf "$TEMP_DIR" # cleanup
}

# Install shfmt VIA THE GITHUB RELEASE PAGE under the directory 'DEVEL_TOOLS_DIR'.
#
# Note that install not via Golang (download binary from GitHub Release page).
#
# Ref:
#   https://github.com/mvdan/sh#shfmt
#   https://github.com/mvdan/sh/releases
install_shfmt() {
  cd "$DEVEL_TOOLS_DIR"
  curl -L "$SHFMT_URL" -o shfmt
  chmod +x ./shfmt
}

main
