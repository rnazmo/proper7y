#!/bin/bash
set -eu

# What is this:
#   - Compose and export the global variables
#   - Export some functions
#   This file will be loaded from the following files:
#     run-lint.linux-x64.sh
#     install-dependencies-for-devel.linux-x64.sh
#
# How to load this file:
#   Like this:
#
#     source "$(dirname "$0")/common.sh"
#
#   Prerequiste: Place this file and the file you want to load this file
#   into the same direcotry.
#
#   NOTE: You must add '--exclude SC1009"' option when you run shellcheck
#   to your bash script to avoid error.
#
# NOTE:
#   - You SHOULD NOT CALL any function whose name starts with '_'
#     except the _set_global_variables function.

# Global Variables
PROJECT_ROOT="This_value_should_be_overridden"
DEVEL_TOOLS_DIR="This_value_should_be_overridden"
COMMON_SH_PATH="This_value_should_be_overridden"
SHELLCHECK_CMD_PATH="This_value_should_be_overridden"
SHFMT_CMD_PATH="This_value_should_be_overridden"

_main() {
  _set_global_variables
}

_set_global_variables() {
  # Override abobe global variables. Be careful about the order of
  # calling these functions.
  _compose_project_root_dir
  _compse_devel_tools_dir
  _compose_shellcheck_cmd_path
  _compose_shfmt_cmd_path
}

# _get_script_dir returns the directory where this file is placed.
# Ref: https://stackoverflow.com/q/59895
_get_script_dir() {
  dirname "$0"
}

# _get_script_dir composes the project (= 'property') root directory
# in absolute path.
_compose_project_root_dir() {
  local SCRIPT_DIR
  SCRIPT_DIR="$(_get_script_dir)"

  PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." &>/dev/null && pwd)"
}

_compse_devel_tools_dir() {
  DEVEL_TOOLS_DIR="${PROJECT_ROOT}/devel-tools/bin"

  echo "INFO: DEVEL_TOOLS_DIR: $DEVEL_TOOLS_DIR"
}

_compse_common_sh_path() {
  COMMON_SH_PATH="${PROJECT_ROOT}/devel-tools/bin"

  echo "INFO: COMMON_SH_PATH: $COMMON_SH_PATH"
}

# Note that this does not return a string,
# but set global variable SHELLCHECK_CMD_PATH.
_compose_shellcheck_cmd_path() {
  SHELLCHECK_CMD_PATH="${DEVEL_TOOLS_DIR}/shellcheck"

  echo "INFO: SHELLCHECK_CMD_PATH: $SHELLCHECK_CMD_PATH"
}

# Note that this does not return a string,
# but set global variable SHFMT_CMD_PATH.
_compose_shfmt_cmd_path() {
  SHFMT_CMD_PATH="${DEVEL_TOOLS_DIR}/shfmt"

  echo "INFO: SHFMT_CMD_PATH: $SHFMT_CMD_PATH"
}

# Check if the SHELLCHECK_CMD_PATH exists and is a exectable file.
# If it does, do nothing; if it does not, exit with status code 1.
check_if_shellcheck_exists() {
  echo "INFO: Checking if the SHELLCHECK_CMD_PATH exists and a exectable file..."
  if [ ! -x "$SHELLCHECK_CMD_PATH" ]; then
    echo "INFO: SHELLCHECK_CMD_PATH: $SHELLCHECK_CMD_PATH"
    echo "ERROR: $SHELLCHECK_CMD_PATH not found."
    echo "ERROR: Please install it before run this script."
    echo "ERROR: (You should run install-dependencies-for-devel.linux-x64.sh to install.)"
    exit 1
  fi
  echo "INFO: Checked that shellcheck is installed"
}

# Almost same as check_if_shellcheck_exists
check_if_shfmt_exists() {
  echo "INFO: Checking if the SHFMT_CMD_PATH exists and a exectable file..."
  if [ ! -x "$SHFMT_CMD_PATH" ]; then
    echo "INFO: SHFMT_CMD_PATH: $SHFMT_CMD_PATH"
    echo "ERROR: $SHFMT_CMD_PATH not found."
    echo "ERROR: Please install it before run this script."
    echo "ERROR: (You should run install-dependencies-for-devel.linux-x64.sh to install.)"
    exit 1
  fi
  echo "INFO: Checked that shfmt is installed"
}

print_shellcheck_version() {
  echo "INFO: Version of the shellcheck is:"
  "$SHELLCHECK_CMD_PATH" --version
}

print_shfmt_version() {
  echo "INFO: Version of the shfmt is:"
  "$SHFMT_CMD_PATH" --version
}

_main
