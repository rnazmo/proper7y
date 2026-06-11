#!/usr/bin/env bash
set -euo pipefail

# What is this:
#   - Compose and export the global variables
#   - Export some functions
#   This file will be loaded from the following files:
#     install-devel-tools.linux-x64.bash
#     bump-project.linux-x64.bash
#     run-lint.linux-x64.bash
#     run-format.linux-x64.bash
#     run-integ-test.bash
#     etc...
#
# How to load this file:
#   Like this:
#
#     source "$(dirname "$0")/common.bash"
#     initialize_global_variables
#
#   Prerequiste: Place this file and the file you want to load this file
#   into the same direcotry.
#
#   NOTE:
#     - You must run `initialize_global_variables` whenever you "source" this file.
#     - You must add '--exclude SC1091"' option when you run shellcheck
#       to your bash script to avoid error.
#
# NOTE:
#   - Functions prefixed with '_' are internal to this file.
#     Calling them from another file (e.g. via source) is prohibited.
#     Calling them from within this file is allowed.

# Global Variables
# shellcheck disable=SC2034

# ============================================================
# Variable classification:
#
#   Class A (config values):
#     Set once at startup, never change thereafter.
#     Examples: PROPER7Y_VERSION, PROJECT_ROOT, SHELLCHECK_CMD_PATH
#
#   Class B (user-configured version strings):
#     Written in this file as the "expected" version of each tool.
#     Updated only via overwrite_version_number_variable() during a
#     version bump workflow. Must not be modified elsewhere.
#     Examples: SHELLCHECK_CURRENT_VERSION, SHFMT_CURRENT_VERSION
#
#   Class C (runtime-fetched values):
#     Obtained by executing a binary (e.g. `shellcheck --version`).
#     Updated by _compose_*() / _recompose_*() after any install or
#     upgrade. The hardest class to track: always call the appropriate
#     _recompose_*() after touching the binary.
#     Examples: SHELLCHECK_BINARY_VERSION, SHFMT_BINARY_VERSION
#
# Ownership rules:
#   Class A  — written once by _set_global_path_variables(); readonly after that.
#   Class B  — written by overwrite_version_number_variable() only.
#   Class C  — written by _compose_*() / _recompose_*() only.
#              Never set these directly from other functions.
# ============================================================

# ============================================================
# Class A: True constants (never change)
# ============================================================
readonly PROPER7Y_VERSION="v0.10.1"
readonly SHELLCHECK_TOOL_NAME="shellcheck"
readonly SHFMT_TOOL_NAME="shfmt"
readonly BATS_TOOL_NAME="bats"

# ============================================================
# Class A: Path variables (set once by initialize_global_variables, then immutable)
# ============================================================
# NOTE: Do not use these before calling initialize_global_variables().
PROJECT_ROOT=""
DEVEL_TOOLS_DIR=""
DEVEL_TOOLS_BIN_DIR=""
COMMON_SH_PATH=""
SHELLCHECK_CMD_PATH=""
SHFMT_CMD_PATH=""
BATS_CMD_PATH=""

# ============================================================
# Class B / Class C: Mutable variables (may change during execution)
# ============================================================
# NOTE: Do not use these before calling initialize_global_variables().
# NOTE: After modifying SHELLCHECK_CURRENT_VERSION or SHFMT_CURRENT_VERSION,
#       always call reinitialize_version_dependent_vars().
SHELLCHECK_CURRENT_VERSION="v0.11.0" # Class B
SHFMT_CURRENT_VERSION="v3.13.0"      # Class B
BATS_CURRENT_VERSION="v1.13.0"       # Class B
SHELLCHECK_BINARY_VERSION=""         # Class C
SHFMT_BINARY_VERSION=""              # Class C
BATS_BINARY_VERSION=""               # Class C

# Initialize all global variables.
#
# NOTE:
#   - **Must be called explicitly by each script that sources this file.**
#   - Call this function EXACTLY ONCE per process.
#     Calling it a second time will cause a fatal error because the internal
#     helper functions (_compose_project_root_dir, etc.) declare variables with
#     'readonly'.
initialize_global_variables() {
  log_info "Initializing global variables..."
  _set_global_path_variables
  _set_mutable_global_variables
  log_info "Initialized."
}

# Re-initialize variables that depend on SHELLCHECK_CURRENT_VERSION
# or SHFMT_CURRENT_VERSION.
# NOTE: Call this after modifying either of them.
reinitialize_version_dependent_vars() {
  _set_mutable_global_variables
}

_set_global_path_variables() {
  log_info "Composing global path variables..."
  # Override abobe global variables. Be careful about the order of
  # calling these functions.
  _compose_project_root_dir
  _compose_devel_tools_dir
  _compose_devel_tools_bin_dir
  _compose_common_sh_path
  _compose_shellcheck_cmd_path
  _compose_shfmt_cmd_path
  _compose_bats_cmd_path
  log_info "Composed global path variables."
}

_set_mutable_global_variables() {
  log_info "Composing mutable global variables..."
  # Override abobe global variables. Be careful about the order of
  # calling these functions.
  _compose_shellcheck_binary_version
  _compose_shfmt_binary_version
  _compose_bats_binary_version
  log_info "Composed mutable global variables."
}

# _get_script_dir returns the directory where this file is placed.
# Ref: https://stackoverflow.com/q/59895
_get_script_dir() {
  dirname "${BASH_SOURCE[0]}"
}

# _get_script_dir composes the project (= 'proper7y') root directory
# in absolute path.
_compose_project_root_dir() {
  local -r SCRIPT_DIR="$(_get_script_dir)"

  PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." &>/dev/null && pwd)"
  readonly PROJECT_ROOT
}

_compose_devel_tools_dir() {
  DEVEL_TOOLS_DIR="${PROJECT_ROOT}/devel-tools"
  readonly DEVEL_TOOLS_DIR
  local -r ROW="$(compose_row_for_variable_log "DEVEL_TOOLS_DIR" "$DEVEL_TOOLS_DIR")"
  log_info "$ROW"
}

_compose_devel_tools_bin_dir() {
  DEVEL_TOOLS_BIN_DIR="${DEVEL_TOOLS_DIR}/bin"
  readonly DEVEL_TOOLS_BIN_DIR
  local -r ROW="$(compose_row_for_variable_log "DEVEL_TOOLS_BIN_DIR" "$DEVEL_TOOLS_BIN_DIR")"
  log_info "$ROW"
}

_compose_common_sh_path() {
  COMMON_SH_PATH="${DEVEL_TOOLS_DIR}/script/common.bash"
  readonly COMMON_SH_PATH
  local -r ROW="$(compose_row_for_variable_log "COMMON_SH_PATH" "$COMMON_SH_PATH")"
  log_info "$ROW"
}

# Note that this does not return a string,
# but set global variable SHELLCHECK_CMD_PATH.
_compose_shellcheck_cmd_path() {
  SHELLCHECK_CMD_PATH="${DEVEL_TOOLS_BIN_DIR}/shellcheck"
  readonly SHELLCHECK_CMD_PATH
  local -r ROW="$(compose_row_for_variable_log "SHELLCHECK_CMD_PATH" "$SHELLCHECK_CMD_PATH")"
  log_info "$ROW"
}

_compose_bats_cmd_path() {
  BATS_CMD_PATH="${DEVEL_TOOLS_BIN_DIR}/bats"
  readonly BATS_CMD_PATH
  local -r ROW="$(compose_row_for_variable_log "BATS_CMD_PATH" "$BATS_CMD_PATH")"
  log_info "$ROW"
}

# Note that this does not return a string,
# but set global variable SHFMT_CMD_PATH.
_compose_shfmt_cmd_path() {
  SHFMT_CMD_PATH="${DEVEL_TOOLS_BIN_DIR}/shfmt"
  readonly SHFMT_CMD_PATH
  local -r ROW="$(compose_row_for_variable_log "SHFMT_CMD_PATH" "$SHFMT_CMD_PATH")"
  log_info "$ROW"
}

# TL;DR (What is this?):
#   Update the global variable (SHELLCHECK_BINARY_VERSION).
#
# Usage:
#   _compose_shellcheck_binary_version
#
# NOTE:
#   Call this after any change to the shellcheck binary (install, upgrade, etc.).
#   Do not declare SHELLCHECK_BINARY_VERSION as readonly: it is updated on reinstall.
_compose_shellcheck_binary_version() {
  # Check if the TOOL exists and is a executable file.
  log_info "Checking if the $SHELLCHECK_CMD_PATH exists and a executable file..."
  if [[ ! -x "$SHELLCHECK_CMD_PATH" ]]; then
    log_warn "Checking if the $SHELLCHECK_CMD_PATH exists and a executable file..."
    log_warn "$SHELLCHECK_CMD_PATH not found."
    SHELLCHECK_BINARY_VERSION="$SHELLCHECK_CMD_PATH not found."

    # Note that return 0 not 1. Or, it fails to install the devel-tools
    # when the devel-tools does not exist.
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

# TL;DR (What is this?):
#   Update the global variable (SHFMT_BINARY_VERSION).
#
# Usage:
#   _compose_shfmt_binary_version
#
# NOTE:
#   Call this after any change to the shfmt binary (install, upgrade, etc.).
#   Do not declare SHFMT_BINARY_VERSION as readonly: it is updated on reinstall.
_compose_shfmt_binary_version() {
  # Check if the TOOL exists and is a executable file.
  log_info "Checking if the $SHFMT_CMD_PATH exists and a executable file..."
  if [[ ! -x "$SHFMT_CMD_PATH" ]]; then
    log_warn "Checking if the $SHFMT_CMD_PATH exists and a executable file..."
    log_warn "$SHFMT_CMD_PATH not found."
    SHFMT_BINARY_VERSION="$SHFMT_CMD_PATH not found."

    # Note that return 0 not 1. Or, it fails to install the devel-tools
    # when the devel-tools does not exist.
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
_recompose_shellcheck_binary_version() {
  _compose_shellcheck_binary_version
}

# Update(Re-compose) the variable 'SHFMT_BINARY_VERSION'.
#
# NOTE:
#   You should always **call this function after making any changes to the binary**.
#   Or, the versions of the variable(SHFMT_BINARY_VERSION) and the binary
#   (/devel-tools/bin/shfmt) may not correspond.
_recompose_shfmt_binary_version() {
  _compose_shfmt_binary_version
}

_compose_bats_binary_version() {
  log_info "Checking if the $BATS_CMD_PATH exists and is an executable file..."
  if [[ ! -x "$BATS_CMD_PATH" ]]; then
    log_warn "$BATS_CMD_PATH not found."
    BATS_BINARY_VERSION="$BATS_CMD_PATH not found."
    return 0
  fi

  # Here is the example version info:
  #   $ ./devel-tools/bin/bats --version
  #   Bats 1.13.0
  BATS_BINARY_VERSION="v$($BATS_CMD_PATH --version | sed 's/Bats //')"
}

_recompose_bats_binary_version() {
  _compose_bats_binary_version
}

# Check if the DEVEL_TOOLS_BIN_DIR exists and is a directory.
check_if_devel_tools_bin_dir_exists() {
  if [[ -e "$DEVEL_TOOLS_BIN_DIR" ]] && [[ ! -d "$DEVEL_TOOLS_BIN_DIR" ]]; then
    log_err "The path $DEVEL_TOOLS_BIN_DIR should be a directory not a file."
    return 1
  elif [[ ! -d "$DEVEL_TOOLS_BIN_DIR" ]]; then
    mkdir "$DEVEL_TOOLS_BIN_DIR"
    return 0
  fi
}

# Install shellcheck via the GitHub Releases Page as the file 'SHELLCHECK_CMD_PATH'.
# Ref: https://github.com/koalaman/shellcheck#installing
install_shellcheck() {
  # Run in a subshell so that `trap EXIT` is scoped to this subshell only.
  # Without this, trap would overwrite any existing EXIT trap in the parent
  # shell, potentially causing other cleanup handlers to be silently dropped.
  (
    # NOTE: This URL depends on the GitHub release naming convention.
    # If shellcheck changes its asset names, update the URL accordingly.
    local -r SHELLCHECK_URL="https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK_CURRENT_VERSION}/shellcheck-${SHELLCHECK_CURRENT_VERSION}.linux.x86_64.tar.xz"

    local -r TEMP_DIR="$(mktemp -d)"
    # The trap fires when this subshell exits (success or failure).
    # No need to `cd` back to PROJECT_ROOT: subshell exit restores the
    # working directory automatically in the parent shell.
    trap 'rm -rf "${TEMP_DIR:-}"' EXIT
    cd "$TEMP_DIR"
    log_info "TEMP_DIR: $TEMP_DIR"
    log_info "PWD: $(pwd)"

    curl -OL "$SHELLCHECK_URL"
    tar -xf "./shellcheck-${SHELLCHECK_CURRENT_VERSION}.linux.x86_64.tar.xz"
    mv -f "./shellcheck-${SHELLCHECK_CURRENT_VERSION}/shellcheck" "$SHELLCHECK_CMD_PATH"
  )

  # Must be called outside the subshell because subshell variable changes
  # do not propagate to the parent shell.
  _recompose_shellcheck_binary_version
}

# Install shfmt VIA THE GITHUB RELEASE PAGE under the directory 'DEVEL_TOOLS_BIN_DIR'.
#
# Note that install not via Golang (download binary from GitHub Release page).
#
# Ref:
#   https://github.com/mvdan/sh#shfmt
#   https://github.com/mvdan/sh/releases
install_shfmt() {
  (
    # NOTE: This URL depends on the GitHub release naming convention.
    # If shfmt changes its asset names, update the URL accordingly.
    local -r SHFMT_URL="https://github.com/mvdan/sh/releases/download/${SHFMT_CURRENT_VERSION}/shfmt_${SHFMT_CURRENT_VERSION}_linux_amd64"

    local -r TEMP_DIR="$(mktemp -d)"
    trap 'rm -rf "${TEMP_DIR:-}"' EXIT
    cd "$TEMP_DIR"

    curl -L "$SHFMT_URL" -o shfmt
    mv -f "./shfmt" "$SHFMT_CMD_PATH"
    chmod +x "$SHFMT_CMD_PATH"
  )

  _recompose_shfmt_binary_version
}

# Install bats-core via the GitHub Releases tarball under DEVEL_TOOLS_BIN_DIR.
#
# Unlike single-binary tools (shellcheck, shfmt), bats requires multiple files:
# bin/bats, libexec/bats-core/, and optionally share/man/.
#
# We install bats to devel-tools/opt/bats/ (self-contained installation)
# and create a symlink from devel-tools/bin/bats for consistent access.
# See ADR-031 for the design rationale.
#
# Ref: https://github.com/bats-core/bats-core/releases
install_bats() {
  (
    # NOTE: This URL depends on the GitHub release naming convention.
    # If bats-core changes its tag/asset names, update the URL accordingly.
    local -r BATS_VERSION_WITHOUT_V="${BATS_CURRENT_VERSION#v}"
    local -r BATS_URL="https://github.com/bats-core/bats-core/archive/refs/tags/${BATS_CURRENT_VERSION}.tar.gz"
    local -r BATS_INSTALL_PREFIX="${DEVEL_TOOLS_DIR}/opt/bats"

    local -r TEMP_DIR="$(mktemp -d)"
    trap 'rm -rf "${TEMP_DIR:-}"' EXIT
    cd "$TEMP_DIR"
    log_info "TEMP_DIR: $TEMP_DIR"

    curl -OL "$BATS_URL"
    tar -xf "${BATS_CURRENT_VERSION}.tar.gz"

    # Install to devel-tools/opt/bats/ for self-contained layout
    bash "./bats-core-${BATS_VERSION_WITHOUT_V}/install.sh" "$BATS_INSTALL_PREFIX"
  )

  # Create symlink from devel-tools/bin/bats to opt/bats/bin/bats
  # for consistent access with other devel-tools
  ln -sf "../opt/bats/bin/bats" "$BATS_CMD_PATH"

  _recompose_bats_binary_version
}

reinstall_bats() {
  install_bats
  check_bats_is_ready
}

reinstall_shellcheck() {
  install_shellcheck
  check_shellcheck_is_ready
}

reinstall_shfmt() {
  install_shfmt
  check_shfmt_is_ready
}

_check_if_shellcheck_exists() {
  _check_if_the_tool_exists "$SHELLCHECK_TOOL_NAME" "$SHELLCHECK_CMD_PATH"
}
_check_if_shfmt_exists() {
  _check_if_the_tool_exists "$SHFMT_TOOL_NAME" "$SHFMT_CMD_PATH"
}
# Check if the TOOL exists and is a executable file.
# If it does, do nothing; if it does not, return status code 1.
_check_if_the_tool_exists() {
  local -r TOOL_NAME="$1"
  local -r TOOL_PATH="$2"
  log_info "Checking if the $TOOL_PATH exists and a executable file..."
  if [[ ! -x "$TOOL_PATH" ]]; then
    log_info "  TOOL_PATH: $TOOL_PATH"
    log_err "$TOOL_PATH not found."
    log_err "Please install it before run this script."
    log_err "(You should run install-devel-tools.linux-x64.bash to install.)"
    # Use 'return 1' here (not 'exit') because this is a library function.
    # The caller decides whether to abort. See ADR-008.
    return 1
  fi
  log_info "  => Checked that $TOOL_NAME is installed"
}

# Compare the 'Current version' and the 'Binary version'.
# TODO: Refactor this func (Using SHELLCHECK_CURRENT_VERSION and SHELLCHECK_BINARY_VERSION variables?)
_check_if_installed_shellcheck_version_is_correct() {
  _recompose_shellcheck_binary_version # Update the variable just in case.
  compare_binary_ver_with_current_ver_of_the_devel_tool "$SHELLCHECK_TOOL_NAME" "$SHELLCHECK_BINARY_VERSION" "$SHELLCHECK_CURRENT_VERSION"
}

# Compare the 'Current version' and the 'Binary version'.
# TODO: Refactor this func (Using SHFMT_CURRENT_VERSION and SHFMT_BINARY_VERSION variables?)
_check_if_installed_shfmt_version_is_correct() {
  _recompose_shfmt_binary_version # Update the variable just in case.
  compare_binary_ver_with_current_ver_of_the_devel_tool "$SHFMT_TOOL_NAME" "$SHFMT_BINARY_VERSION" "$SHFMT_CURRENT_VERSION"
}

compare_binary_ver_with_current_ver_of_the_devel_tool() {
  local -r TOOL_NAME="$1"
  local -r BINARY_VERSION="$2"
  local -r CURRENT_VERSION="$3"
  log_info "Checking that the version of installed $TOOL_NAME is the one expected."
  if [[ "$BINARY_VERSION" != "$CURRENT_VERSION" ]]; then
    log_err "The versions of $TOOL_NAME does not correspond."
    log_err "  Binary version : $BINARY_VERSION"
    log_err "  Current version: $CURRENT_VERSION"
    return 1
  fi
  log_info "  => Checked that the version of $TOOL_NAME is correct."
}

# Overwrite a version number variable in a given file.
#
# This function replaces a line like:
#   VARIABLE_NAME="vX.X.X"
# with:
#   VARIABLE_NAME="vY.Y.Y"
#
# By including the variable name in the replacement pattern,
# this avoids accidentally overwriting unrelated lines that
# happen to contain the same version string.
#
# Usage:
#   overwrite_version_number_variable <file> <variable_name> <old_version> <new_version>
#
# Example:
#   overwrite_version_number_variable "./common.bash" "SHELLCHECK_CURRENT_VERSION" "v0.9.0" "v0.10.0"
overwrite_version_number_variable() {
  local -r TARGET_FILE="$1"
  local -r VARIABLE_NAME="$2"
  local -r VERSION_OLD="$3"
  local -r VERSION_NEW="$4"
  log_info "Overwrite the version in the target: START"
  log_info "  TARGET: $TARGET_FILE"

  local -r OLD="$VARIABLE_NAME=\"$VERSION_OLD\""
  local -r NEW="$VARIABLE_NAME=\"$VERSION_NEW\""

  sed -i "s/${OLD}/${NEW}/" "$TARGET_FILE"

  log_info "Overwrite the version in the target: END"
}

# Verify that PROPER7Y_VERSION is consistent across all three files
# that define it: proper7y, install.bash, and common.bash.
#
# Background:
#   These three files each define PROPER7Y_VERSION independently
#   because proper7y and install.bash are distributed as standalone
#   scripts and cannot source common.bash. This makes version
#   duplication an unavoidable structural constraint of this project.
#
# Purpose:
#   Since the version must be kept in sync manually (via
#   bump-project.linux-x64.bash), this function acts as a safety net
#   to catch any inconsistency immediately after the version bump,
#   before the change is committed.
#
# Usage:
#   verify_version_consistency "$NEW_PROPER7Y_VERSION"
verify_version_consistency() {
  local -r EXPECTED="$1"

  local -r VERSION_IN_PROPER7Y="$(grep '^readonly PROPER7Y_VERSION=' "${PROJECT_ROOT}/proper7y" |
    head -1 | sed 's/.*="\(.*\)"/\1/')"
  local -r VERSION_IN_INSTALL="$(grep '^readonly PROPER7Y_VERSION=' "${PROJECT_ROOT}/install.bash" |
    head -1 | sed 's/.*="\(.*\)"/\1/')"
  local -r VERSION_IN_COMMON="$(grep '^readonly PROPER7Y_VERSION=' "${COMMON_SH_PATH}" |
    head -1 | sed 's/.*="\(.*\)"/\1/')"

  log_info "Verifying version consistency..."
  log_info "  proper7y    : $VERSION_IN_PROPER7Y"
  log_info "  install.bash: $VERSION_IN_INSTALL"
  log_info "  common.bash : $VERSION_IN_COMMON"

  if [[ "$VERSION_IN_PROPER7Y" != "$EXPECTED" ]] ||
    [[ "$VERSION_IN_INSTALL" != "$EXPECTED" ]] ||
    [[ "$VERSION_IN_COMMON" != "$EXPECTED" ]]; then
    log_err "Version mismatch detected! All three files must have: $EXPECTED"
    return 1
  fi

  log_info "  => All versions are consistent."
}

check_shellcheck_is_ready() {
  log_info "Checking shellcheck is ready..."
  _check_if_shellcheck_exists || return 1
  _check_if_installed_shellcheck_version_is_correct || return 1
  log_info "Checked. shellcheck is ready!"
  print_shellcheck_current_version
}

check_shfmt_is_ready() {
  log_info "Checking shfmt is ready..."
  _check_if_shfmt_exists || return 1
  _check_if_installed_shfmt_version_is_correct || return 1
  log_info "Checked. shfmt is ready!"
  print_shfmt_current_version
}

_check_if_bats_exists() {
  _check_if_the_tool_exists "$BATS_TOOL_NAME" "$BATS_CMD_PATH"
}

_check_if_installed_bats_version_is_correct() {
  _recompose_bats_binary_version
  compare_binary_ver_with_current_ver_of_the_devel_tool "$BATS_TOOL_NAME" "$BATS_BINARY_VERSION" "$BATS_CURRENT_VERSION"
}

check_bats_is_ready() {
  log_info "Checking bats is ready..."
  _check_if_bats_exists || return 1
  _check_if_installed_bats_version_is_correct || return 1
  log_info "Checked. bats is ready!"
  log_info "bats 'Current version': $BATS_CURRENT_VERSION"
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
    log_info "Aborted."
    return 1
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
#   compose_row_for_variable_log "DEVEL_TOOLS_BIN_DIR" "/foo/bar/baz/proper7y/devel-tools/bin"
#
compose_row_for_variable_log() {
  local -r ROW_NAME="$1"
  local -r ROW_VALUE="$2"
  local -r ROW_NAME_PADDED="$(pad_with_spaces "$ROW_NAME")"

  echo "  ${ROW_NAME_PADDED}: ${ROW_VALUE}"
}

log_debug() {
  local -r PREFIX="DEBUG:"
  echo "$PREFIX $1"
}

log_info() {
  local -r PREFIX="INFO :"
  echo "$PREFIX $1"
}

log_warn() {
  local -r PREFIX="WARN :"
  echo "$PREFIX $1" >&2
}

log_err() {
  local -r PREFIX="ERROR:"
  echo "$PREFIX $1" >&2
}
