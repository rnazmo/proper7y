#!/bin/bash
set -eu

# What is this:
#   - Compose and export the global variables
#   - Export some functions
#   This file will be loaded from the following files:
#     install-devel-tools.linux-x64.sh
#     bump-project.linux-x64.sh
#     run-lint.linux-x64.sh
#     run-format.linux-x64.sh
#     run-integ-test.linux-x64.sh
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
# shellcheck disable=SC2034
PROPERTY_VERSION="v0.1.6"
SHELLCHECK_VERSION="v0.8.0"
SHFMT_VERSION="v3.3.0"
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
  local -r SCRIPT_DIR="$(_get_script_dir)"

  PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." &>/dev/null && pwd)"
}

_compse_devel_tools_dir() {
  DEVEL_TOOLS_DIR="${PROJECT_ROOT}/devel-tools/bin"

  log_info "DEVEL_TOOLS_DIR: $DEVEL_TOOLS_DIR"
}

_compse_common_sh_path() {
  COMMON_SH_PATH="${PROJECT_ROOT}/devel-tools/bin"

  log_info "COMMON_SH_PATH: $COMMON_SH_PATH"
}

# Note that this does not return a string,
# but set global variable SHELLCHECK_CMD_PATH.
_compose_shellcheck_cmd_path() {
  SHELLCHECK_CMD_PATH="${DEVEL_TOOLS_DIR}/shellcheck"

  log_info "SHELLCHECK_CMD_PATH: $SHELLCHECK_CMD_PATH"
}

# Note that this does not return a string,
# but set global variable SHFMT_CMD_PATH.
_compose_shfmt_cmd_path() {
  SHFMT_CMD_PATH="${DEVEL_TOOLS_DIR}/shfmt"

  log_info "SHFMT_CMD_PATH: $SHFMT_CMD_PATH"
}

# Check if the SHELLCHECK_CMD_PATH exists and is a exectable file.
# If it does, do nothing; if it does not, exit with status code 1.
_check_if_shellcheck_exists() {
  log_info "Checking if the SHELLCHECK_CMD_PATH exists and a exectable file..."
  if [ ! -x "$SHELLCHECK_CMD_PATH" ]; then
    log_info "SHELLCHECK_CMD_PATH: $SHELLCHECK_CMD_PATH"
    log_err "$SHELLCHECK_CMD_PATH not found."
    log_err "Please install it before run this script."
    log_err "(You should run install-devel-tools.linux-x64.sh to install.)"
    exit 1
  fi
  log_info "Checked that shellcheck is installed"
}

# Almost same as check_if_shellcheck_exists
_check_if_shfmt_exists() {
  log_info "Checking if the SHFMT_CMD_PATH exists and a exectable file..."
  if [ ! -x "$SHFMT_CMD_PATH" ]; then
    log_info "SHFMT_CMD_PATH: $SHFMT_CMD_PATH"
    log_err "$SHFMT_CMD_PATH not found."
    log_err "Please install it before run this script."
    log_err "(You should run install-devel-tools.linux-x64.sh to install.)"
    exit 1
  fi
  log_info "Checked that shfmt is installed"
}

_check_if_installed_shellcheck_version_is_correct() {
  local -r TARGET_NAME="shellcheck"
  log_info "Checking that the version of $TARGET_NAME is the one expected."

  # Here is the example version info:
  #   $ ./devel-tools/bin/shellcheck --version
  #   ShellCheck - shell script analysis tool
  #   version: 0.7.2
  #   license: GNU General Public License, version 3
  #   website: https://www.shellcheck.net
  #
  local -r SHELLCHECK_VERSION_WITHOUT_PREFIX="${SHELLCHECK_VERSION#'v'}"
  local -r PATTERN="version: ${SHELLCHECK_VERSION_WITHOUT_PREFIX}"
  if ! "$SHELLCHECK_CMD_PATH" --version | grep -q "^${PATTERN}$"; then
    log_err "The version of $TARGET_NAME is wrong (or failed to parse the version info)."
    log_err "  Expected version: $SHELLCHECK_VERSION_WITHOUT_PREFIX"
    log_err "  Got version info:"
    $SHELLCHECK_CMD_PATH --version
    exit 1
  fi

  log_info "Checked that the version of $TARGET_NAME is correct."
}

_check_if_installed_shfmt_version_is_correct() {
  local -r TARGET_NAME="shfmt"
  log_info "Checking that the version of $TARGET_NAME is the one expected."

  # Here is the example version info:
  #   $ ./devel-tools/bin/shfmt --version
  #   v3.3.0
  #
  local -r PATTERN="$SHFMT_VERSION"
  if ! "$SHFMT_CMD_PATH" --version | grep -q "^${PATTERN}$"; then
    log_err "The version of $TARGET_NAME is wrong (or failed to parse the version info)."
    log_err "  Expected version: $SHFMT_VERSION"
    log_err "  Got version info:"
    $SHFMT_CMD_PATH --version
    exit 1
  fi

  log_info "Checked that the version of $TARGET_NAME is correct."
}

check_shellcheck_is_ready() {
  log_info "Checking shellcheck is ready..."
  _check_if_shellcheck_exists
  _check_if_installed_shellcheck_version_is_correct
  log_info "Checked. shellcheck is ready!"
  print_shellcheck_version
}

check_shfmt_is_ready() {
  log_info "Checking shfmt is ready..."
  _check_if_shfmt_exists
  _check_if_installed_shfmt_version_is_correct
  log_info "Checked. shfmt is ready!"
  print_shfmt_version
}

print_shellcheck_version() {
  log_info "Version of the shellcheck is:"
  "$SHELLCHECK_CMD_PATH" --version
}

print_shfmt_version() {
  log_info "Version of the shfmt is:"
  "$SHFMT_CMD_PATH" --version
}

confirm_continue() {
  read -p "Continue? [y/N]" -n 1 -r
  echo # Print new line (optional)
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    [[ "$0" = "${BASH_SOURCE[0]}" ]] && exit 1 || exit 1
  fi
}

log_info() {
  local -r PREFIX="INFO :"
  echo "$PREFIX $1"
}
log_warn() {
  local -r PREFIX="WARN :"
  echo "$PREFIX $1"
}
log_err() {
  local -r PREFIX="ERROR:"
  echo "$PREFIX $1"
}

_main
