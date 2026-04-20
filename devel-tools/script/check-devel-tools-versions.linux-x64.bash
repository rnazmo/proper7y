#!/usr/bin/env bash
set -eu

# Tl;DR (What is this?)
#   Print following three versions of the devel-tools:
#     'Current version': The expected version written in the `/devel-tools/script/common.bash`.
#     'Binary version' : The actual version shown by the binaries under `/devel-tools/bin/`.
#     'Latest version' : The latest version shown by the GitHub latest release page URL

source "$(dirname "$0")/common.bash"
initialize_global_variables

main() {
  log_info "Start checking..."
  log_info "(This takes a few seconds. Wait a few seconds....)"

  local -r SHELLCHECK_CURRENT_VERSION_BEFORE_BUMP="$SHELLCHECK_CURRENT_VERSION"
  local -r SHFMT_CURRENT_VERSION_BEFORE_BUMP="$SHFMT_CURRENT_VERSION"

  local -r SHELLCHECK_OWNER="koalaman"
  local -r SHELLCHECK_REPO="shellcheck"
  local -r SHELLCHECK_LATEST_VERSION="$(get_latest_version_number "$SHELLCHECK_OWNER" "$SHELLCHECK_REPO")"
  print_versions "$SHELLCHECK_TOOL_NAME" "$SHELLCHECK_CURRENT_VERSION" "$SHELLCHECK_BINARY_VERSION" "$SHELLCHECK_LATEST_VERSION"

  local -r SHFMT_OWNER="mvdan"
  local -r SHFMT_REPO="sh"
  local -r SHFMT_LATEST_VERSION="$(get_latest_version_number "$SHFMT_OWNER" "$SHFMT_REPO")"
  print_versions "$SHFMT_TOOL_NAME" "$SHFMT_CURRENT_VERSION" "$SHFMT_BINARY_VERSION" "$SHFMT_LATEST_VERSION"

  # Check: Compare the 'Binary Version' with the 'Current Version'.
  compare_binary_ver_with_current_ver_of_the_devel_tool "$SHELLCHECK_TOOL_NAME" "$SHELLCHECK_BINARY_VERSION" "$SHELLCHECK_CURRENT_VERSION"
  compare_binary_ver_with_current_ver_of_the_devel_tool "$SHFMT_TOOL_NAME" "$SHFMT_BINARY_VERSION" "$SHFMT_CURRENT_VERSION"

  upgrade_devel_tool_if_needed \
    "$SHELLCHECK_TOOL_NAME" \
    "$SHELLCHECK_CURRENT_VERSION" \
    "$SHELLCHECK_LATEST_VERSION" \
    "$SHELLCHECK_CURRENT_VERSION_BEFORE_BUMP" \
    "bump_shellcheck_version" \
    "SHELLCHECK_BINARY_VERSION"

  upgrade_devel_tool_if_needed \
    "$SHFMT_TOOL_NAME" \
    "$SHFMT_CURRENT_VERSION" \
    "$SHFMT_LATEST_VERSION" \
    "$SHFMT_CURRENT_VERSION_BEFORE_BUMP" \
    "bump_shfmt_version" \
    "SHFMT_BINARY_VERSION"

  log_info "Checked all devel-tools!"
}

print_versions() {
  local -r TOOL_NAME="$1"
  local -r TOOL_CURRENT_VERSION="$2"
  local -r TOOL_BINARY_VERSION="$3"
  local -r TOOL_LATEST_VERSION="$4"

  # Print info.
  log_info "  $TOOL_NAME:"
  log_info "    Current version: $TOOL_CURRENT_VERSION"
  log_info "    Binary version : $TOOL_BINARY_VERSION"
  log_info "    Latest version : $TOOL_LATEST_VERSION"
}

# Get the latest version number of the devel-tool.
#
# Example Usage:
#   get_latest_version_number "koalaman" "shellcheck"
#
# Example Result:
#   v0.8.0
#
# MEMO:
#   This uses URL redirecting on GitHub.
#   Redirecting example:
#     https://github.com/koalaman/shellcheck/releases/latest
#     ↓
#     https://github.com/koalaman/shellcheck/releases/tag/v0.8.0
#
# TODO:
#   Should I use a GitHub API instead of the URL?
#     Non-API URL (NOW):
#       like https://github.com/OWNER/REPO/releases/latest
#     API URL:
#       like https://api.github.com/repos/OWNER/REPO/releases/latest
#       Ref: https://docs.github.com/en/rest/releases/releases#get-the-latest-release
#
get_latest_version_number() {
  local -r OWNER="$1"
  local -r REPO="$2"

  REDIRECT_URL="$(curl -w "%{redirect_url}" -s -o /dev/null "https://github.com/${OWNER}/${REPO}/releases/latest")"
  LATEST_VER="$(basename "$REDIRECT_URL")"
  # TODO: Should I validate the LATEST_VER ? (The format is like "v0.0.0"?)
  echo "$LATEST_VER"
}

# TODO: Refactor DRY following two functions
bump_shellcheck_version() {
  # Overwrite devel-tools versions
  local -r TARGET_FILE="${COMMON_SH_PATH}"
  overwrite_version_number_variable "$TARGET_FILE" "SHELLCHECK_CURRENT_VERSION" "$SHELLCHECK_CURRENT_VERSION" "$SHELLCHECK_LATEST_VERSION"

  # TODO: Update global variables in common.bash to support for above change ?
  # (Note especially SHELLCHECK_CURRENT_VERSION and its effect on SHELLCHECK_URL.)

  # Update the in-memory variable to match the rewritten file
  SHELLCHECK_CURRENT_VERSION="$SHELLCHECK_LATEST_VERSION"

  reinstall_shellcheck
}
bump_shfmt_version() {
  # Overwrite devel-tools versions
  local -r TARGET_FILE="${COMMON_SH_PATH}"
  overwrite_version_number_variable "$TARGET_FILE" "SHFMT_CURRENT_VERSION" "$SHFMT_CURRENT_VERSION" "$SHFMT_LATEST_VERSION"

  # TODO: Update global variables in common.bash to support for above change ?
  # (Note especially SHFMT_CURRENT_VERSION and its effect on SHFMT_URL.)

  # Update the in-memory variable to match the rewritten file
  SHFMT_CURRENT_VERSION="$SHFMT_LATEST_VERSION"

  reinstall_shfmt
}

# Upgrade a devel-tool if a newer version is available.
#
# Usage:
#   upgrade_devel_tool_if_needed <tool_name> <current_ver> <latest_ver> <before_bump_ver> <bump_func> <binary_version_var>
#
# Example:
#   upgrade_devel_tool_if_needed \
#     "$SHELLCHECK_TOOL_NAME" \
#     "$SHELLCHECK_CURRENT_VERSION" \
#     "$SHELLCHECK_LATEST_VERSION" \
#     "$SHELLCHECK_CURRENT_VERSION_BEFORE_BUMP" \
#     "bump_shellcheck_version" \
#     "SHELLCHECK_BINARY_VERSION"
upgrade_devel_tool_if_needed() {
  local -r TOOL_NAME="$1"
  local -r CURRENT_VERSION="$2"
  local -r LATEST_VERSION="$3"
  local -r CURRENT_VERSION_BEFORE_BUMP="$4"
  local -r BUMP_FUNC="$5"
  local -r BINARY_VERSION_VAR="$6"

  log_info "Checking that the version of installed $TOOL_NAME is latest."
  if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
    log_info "  => The version is latest."
    return 0
  fi

  # Confirmation ("Upgrade or not") (Using `confirm_continue()` in `common.bash`)
  log_info "  => Latest version found."
  log_warn "Will you upgrade $TOOL_NAME from $CURRENT_VERSION to $LATEST_VERSION ?"
  confirm_continue

  # Check: You must commit all changes before bump devel-tool version. (Or, you can do it manually).
  if ! git diff --quiet; then
    # Check that tracked && (unstaged/staged) file changes not exist.
    log_err "Commit all changes before running this script."
    log_err "(Or, you can bump the devel-tool version without this script (manually).)"
    exit 1
  fi

  # Update the tool (shecllcheck/shfmt) version to latest
  # NOTE: After calling $BUMP_FUNC, the binary version variable (e.g. SHELLCHECK_BINARY_VERSION)
  # is already updated, because $BUMP_FUNC internally calls reinstall_* (in common.bash),
  # which in turn calls _recompose_*_binary_version().
  "$BUMP_FUNC"

  # Print the versions again to check if the upgrade succeeded.
  # TODO: Or, just compare the 'Current Version' with the 'Latest Version'?
  print_versions "$TOOL_NAME" "$CURRENT_VERSION" "${!BINARY_VERSION_VAR}" "$LATEST_VERSION"

  log_info "Here is the git diff:"
  git diff
  confirm_continue

  # Create git commit
  git commit -a -m "chore($TOOL_NAME): Bump devel-tool version: $CURRENT_VERSION_BEFORE_BUMP -> $LATEST_VERSION"
  log_info "Here is the git log:"
  git log -n 3
}

main

exit 0
