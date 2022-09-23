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
#     etc...
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
PROPERTY_VERSION="v0.1.8"
SHELLCHECK_CURRENT_VERSION="v0.8.0"
SHFMT_CURRENT_VERSION="v3.5.1"
SHELLCHECK_BINARY_VERSION="This_value_should_be_overridden"
SHFMT_BINARY_VERSION="This_value_should_be_overridden"
PROJECT_ROOT="This_value_should_be_overridden"
DEVEL_TOOLS_DIR="This_value_should_be_overridden"
DEVEL_TOOLS_BIN_DIR="This_value_should_be_overridden"
COMMON_SH_PATH="This_value_should_be_overridden"
SHELLCHECK_CMD_PATH="This_value_should_be_overridden"
SHFMT_CMD_PATH="This_value_should_be_overridden"
SHELLCHECK_TOOL_NAME="shellcheck"
SHFMT_TOOL_NAME="shfmt"
SHELLCHECK_URL="https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK_CURRENT_VERSION}/shellcheck-${SHELLCHECK_CURRENT_VERSION}.linux.x86_64.tar.xz"
SHFMT_URL="https://github.com/mvdan/sh/releases/download/${SHFMT_CURRENT_VERSION}/shfmt_${SHFMT_CURRENT_VERSION}_linux_amd64"

_main() {
  _set_global_variables
}

_set_global_variables() {
  log_info "Composing golbal variables..."
  # Override abobe global variables. Be careful about the order of
  # calling these functions.
  _compose_project_root_dir
  _compose_devel_tools_dir
  _compose_devel_tools_bin_dir
  _compose_common_sh_path
  _compose_shellcheck_cmd_path
  _compose_shfmt_cmd_path
  _compose_shellcheck_binary_version
  _compose_shfmt_binary_version
  log_info "Composed golbal variables."
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

_compose_devel_tools_dir() {
  DEVEL_TOOLS_DIR="${PROJECT_ROOT}/devel-tools"
  ROW="$(compose_row_for_variable_log "DEVEL_TOOLS_DIR" "$DEVEL_TOOLS_DIR")"
  log_info "$ROW"
}

_compose_devel_tools_bin_dir() {
  DEVEL_TOOLS_BIN_DIR="${DEVEL_TOOLS_DIR}/bin"
  ROW="$(compose_row_for_variable_log "DEVEL_TOOLS_BIN_DIR" "$DEVEL_TOOLS_BIN_DIR")"
  log_info "$ROW"
}

_compose_common_sh_path() {
  COMMON_SH_PATH="${DEVEL_TOOLS_DIR}/script/common.sh"
  ROW="$(compose_row_for_variable_log "COMMON_SH_PATH" "$COMMON_SH_PATH")"
  log_info "$ROW"
}

# Note that this does not return a string,
# but set global variable SHELLCHECK_CMD_PATH.
_compose_shellcheck_cmd_path() {
  SHELLCHECK_CMD_PATH="${DEVEL_TOOLS_BIN_DIR}/shellcheck"
  ROW="$(compose_row_for_variable_log "SHELLCHECK_CMD_PATH" "$SHELLCHECK_CMD_PATH")"
  log_info "$ROW"
}

# Note that this does not return a string,
# but set global variable SHFMT_CMD_PATH.
_compose_shfmt_cmd_path() {
  SHFMT_CMD_PATH="${DEVEL_TOOLS_BIN_DIR}/shfmt"
  ROW="$(compose_row_for_variable_log "SHFMT_CMD_PATH" "$SHFMT_CMD_PATH")"
  log_info "$ROW"
}

# NOTE:
#   You should always **call _compose_shfmt_binary_version()
#   after making any changes to the binary**.
_compose_shellcheck_binary_version() {
  # Check if the TOOL exists and is a exectable file.
  log_info "Checking if the $SHELLCHECK_CMD_PATH exists and a exectable file..."
  if [ ! -x "$SHELLCHECK_CMD_PATH" ]; then
    log_warn "Checking if the $SHELLCHECK_CMD_PATH exists and a exectable file..."
    log_warn "$SHELLCHECK_CMD_PATH not found."
    SHELLCHECK_BINARY_VERSION="$SHELLCHECK_CMD_PATH not found."

    # Note that return 0 not 1. Or, it fails to install the devel-tools
    # when the devel-tools does not exist.exists.
    return 0
  fi

  # Here is the example version info:
  #   $ ./devel-tools/bin/shellcheck --version
  #   ShellCheck - shell script analysis tool
  #   version: 0.7.2
  #   license: GNU General Public License, version 3
  #   website: https://www.shellcheck.net
  SHELLCHECK_BINARY_VERSION="$($SHELLCHECK_CMD_PATH --version | grep "version: " | sed 's/version: /v/')"

  # TODO: Following log is verbose? or should print?
  # ROW="$(compose_row_for_variable_log "SHELLCHECK_BINARY_VERSION" "$SHELLCHECK_BINARY_VERSION")"
  # log_info "$ROW"
}

# NOTE:
#   You should always **call update_shfmt_binary_version()
#   after making any changes to the binary**.
_compose_shfmt_binary_version() {
  # Check if the TOOL exists and is a exectable file.
  log_info "Checking if the $SHFMT_CMD_PATH exists and a exectable file..."
  if [ ! -x "$SHFMT_CMD_PATH" ]; then
    log_warn "Checking if the $SHFMT_CMD_PATH exists and a exectable file..."
    log_warn "$SHFMT_CMD_PATH not found."
    SHFMT_BINARY_VERSION="$SHFMT_CMD_PATH not found."

    # Note that return 0 not 1. Or, it fails to install the devel-tools
    # when the devel-tools does not exist.exists.
    return 0
  fi

  # Here is the example version info:
  #   $ ./devel-tools/bin/shfmt --version
  #   v3.4.3
  SHFMT_BINARY_VERSION="$($SHFMT_CMD_PATH --version)"

  # TODO: Following log is verbose? or should print?
  # ROW="$(compose_row_for_variable_log "SHFMT_BINARY_VERSION" "$SHFMT_BINARY_VERSION")"
  # log_info "$ROW"
}

# Update(Re-compose) the variable 'SHELLCHECK_BINARY_VERSION'.
#
# NOTE:
#   You should always **call this function after making any changes to the binary**.
#   Or, the versions of the variable(SHELLCHECK_BINARY_VERSION) and the binary
#   (/devel-tools/bin/shellcheck) may not correspond.
update_shellcheck_binary_version() {
  _compose_shellcheck_binary_version
}

# Update(Re-compose) the variable 'SHFMT_BINARY_VERSION'.
#
# NOTE:
#   You should always **call this function after making any changes to the binary**.
#   Or, the versions of the variable(SHFMT_BINARY_VERSION) and the binary
#   (/devel-tools/bin/shfmt) may not correspond.
update_shfmt_binary_version() {
  _compose_shfmt_binary_version
}

# Check if the DEVEL_TOOLS_BIN_DIR exists and is a directory.
check_if_devel_tools_bin_dir_exists() {
  if [ -e "$DEVEL_TOOLS_BIN_DIR" ] && [ ! -d "$DEVEL_TOOLS_BIN_DIR" ]; then
    log_err "The path $DEVEL_TOOLS_BIN_DIR sould be a directory not a file."
    exit 1
  elif [ ! -d "$DEVEL_TOOLS_BIN_DIR" ]; then
    mkdir "$DEVEL_TOOLS_BIN_DIR"
  fi
}

# Install shellcheck via the GitHub Releases Page as the file 'SHELLCHECK_CMD_PATH'.
# Ref: https://github.com/koalaman/shellcheck#installing
install_shellcheck() {
  local -r TEMP_DIR="$(mktemp -d)"
  log_info "TEMP_DIR: $TEMP_DIR"

  cd "$TEMP_DIR"
  log_info "PWD: $(pwd)"

  curl -OL "$SHELLCHECK_URL"
  tar -xf "./shellcheck-${SHELLCHECK_CURRENT_VERSION}.linux.x86_64.tar.xz"
  mv -f "./shellcheck-${SHELLCHECK_CURRENT_VERSION}/shellcheck" "$SHELLCHECK_CMD_PATH"

  rm -rf "$TEMP_DIR" # cleanup
}

# Install shfmt VIA THE GITHUB RELEASE PAGE under the directory 'DEVEL_TOOLS_BIN_DIR'.
#
# Note that install not via Golang (download binary from GitHub Release page).
#
# Ref:
#   https://github.com/mvdan/sh#shfmt
#   https://github.com/mvdan/sh/releases
install_shfmt() {
  cd "$DEVEL_TOOLS_BIN_DIR"
  curl -L "$SHFMT_URL" -o shfmt
  chmod +x ./shfmt
}

_check_if_shellcheck_exists() {
  _check_if_the_tool_exists "$SHELLCHECK_TOOL_NAME" "$SHELLCHECK_CMD_PATH"
}
_check_if_shfmt_exists() {
  _check_if_the_tool_exists "$SHFMT_TOOL_NAME" "$SHFMT_CMD_PATH"
}
# Check if the TOOL exists and is a exectable file.
# If it does, do nothing; if it does not, EXIT with status code 1.
_check_if_the_tool_exists() {
  local -r TOOL_NAME="$1"
  local -r TOOL_PATH="$2"
  log_info "Checking if the $TOOL_PATH exists and a exectable file..."
  if [ ! -x "$TOOL_PATH" ]; then
    log_info "  TOOL_PATH: $TOOL_PATH"
    log_err "$TOOL_PATH not found."
    log_err "Please install it before run this script."
    log_err "(You should run install-devel-tools.linux-x64.sh to install.)"
    exit 1
  fi
  log_info "  => Checked that $TOOL_NAME is installed"
}

# Compare the 'Current version' and the 'Binary version'.
# TODO: Refactor this func (Using SHELLCHECK_CURRENT_VERSION and SHELLCHECK_BINARY_VERSION variables?)
_check_if_installed_shellcheck_version_is_correct() {
  update_shellcheck_binary_version # Update the variable just in case.
  compare_binary_ver_with_current_ver_of_the_devel_tool "$SHELLCHECK_TOOL_NAME" "$SHELLCHECK_BINARY_VERSION" "$SHELLCHECK_CURRENT_VERSION"
}

# Compare the 'Current version' and the 'Binary version'.
# TODO: Refactor this func (Using SHFMT_CURRENT_VERSION and SHFMT_BINARY_VERSION variables?)
_check_if_installed_shfmt_version_is_correct() {
  update_shfmt_binary_version # Update the variable just in case.
  compare_binary_ver_with_current_ver_of_the_devel_tool "$SHFMT_TOOL_NAME" "$SHFMT_BINARY_VERSION" "$SHFMT_CURRENT_VERSION"
}

compare_binary_ver_with_current_ver_of_the_devel_tool() {
  local -r TOOL_NAME="$1"
  local -r BINARY_VERSION="$2"
  local -r CURRENT_VERSION="$3"
  log_info "Checking that the version of installed $TOOL_NAME is the one expected."
  if [[ "$BINARY_VERSION" != "$CURRENT_VERSION" ]]; then
    log_err "The versions of $TOOL_NAME does not correspond."
    log_err "  Current version: $BINARY_VERSION"
    log_err "  Binary version : $CURRENT_VERSION"
    exit 1
  fi
  log_info "  => Checked that the version of $TOOL_NAME is correct."
}

check_shellcheck_is_ready() {
  log_info "Checking shellcheck is ready..."
  _check_if_shellcheck_exists
  _check_if_installed_shellcheck_version_is_correct
  log_info "Checked. shellcheck is ready!"
  print_shellcheck_current_version
}

check_shfmt_is_ready() {
  log_info "Checking shfmt is ready..."
  _check_if_shfmt_exists
  _check_if_installed_shfmt_version_is_correct
  log_info "Checked. shfmt is ready!"
  print_shfmt_current_version
}

print_shellcheck_current_version() {
  log_info "shellcheck 'Current version': $SHELLCHECK_CURRENT_VERSION"
}

print_shfmt_current_version() {
  log_info "shfmt 'Current version': $SHFMT_CURRENT_VERSION"
}

confirm_continue() {
  read -p "Continue? [y/N]" -n 1 -r
  echo # Print new line (optional)
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    [[ "$0" = "${BASH_SOURCE[0]}" ]] && exit 1 || exit 1
  fi
}

# Pad right of a given string with spaces.
#
# Example Usage:
#   PADDED_HELLO="pad_with_spaces 'DEVEL_TOOLS_BIN_DIR'"
#
# NOTE:
#   The number '20' is the max length of those variables
#   (DEVEL_TOOLS_BIN_DIR, COMMON_SH_PATH, SHELLCHECK_CMD_PATH).
pad_with_spaces() {
  local -r RAW="$1"
  local -r LENGTH="25"
  printf "%-*s" "$LENGTH" "$RAW"
}

# Compose a row in format using given ROW_NAME and ROW_VALUE.
#
# Example Usage:
#   compose_row_for_variable_log "DEVEL_TOOLS_BIN_DIR" "/foo/bar/baz/property/devel-tools/bin"
#
compose_row_for_variable_log() {
  local -r ROW_NAME="$1"
  local -r ROW_VALUE="$2"
  local -r ROW_NAME_PADDED="$(pad_with_spaces "$ROW_NAME")"

  echo "  ${ROW_NAME_PADDED}: ${ROW_VALUE}"
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
