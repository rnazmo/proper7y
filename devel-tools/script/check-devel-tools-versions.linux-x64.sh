#!/bin/bash
set -eu

# Tl;DR (What is this?)
#   Print following three versions of the devel-tools:
#     'Current version': The expected version written in the `/devel-tools/script/common.sh`.
#     'Binary version' : The actual version shown by the binaries under `/devel-tools/bin/`.
#     'Latest version' : The latest version shown by the GitHub latest release page URL

source "$(dirname "$0")/common.sh"

SHELLCHECK_IS_LATEST="this_value_will_be_overwitten"
SHFMT_IS_LATEST="this_value_will_be_overwitten"

main() {
  log_info "Start checking..."
  log_info "(This takes a few seconds. Wait a few seconds....)"

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

  # Check: Compare the 'Current Version' with the 'Latest Version'
  log_info "Checking that the version of installed $SHELLCHECK_TOOL_NAME is latest."
  if [[ "$SHELLCHECK_CURRENT_VERSION" != "$SHELLCHECK_LATEST_VERSION" ]]; then
    log_info "  => Latest version found."

    # Confirmation ("Upgrade or not") (Using `confirm_continue()` in `common.sh`)
    log_warn "Will you upgrade $SHELLCHECK_TOOL_NAME from $SHELLCHECK_CURRENT_VERSION to $SHELLCHECK_LATEST_VERSION ?"
    confirm_continue

    # Check: You must commit all changes before bump devel-tool version. (Or, you can do it manually).
    if ! git diff --quiet; then
      # Check that tracked && (unstaged/staged) file changes not exist.
      log_err "Commit all changes before running this script."
      log_err "(Or, you can bump the devel-tool version without this script (manually).)"
      exit 1
    fi

    # Update shecllcheck version to latest
    bump_shellcheck_version

    # Print the versions again to check if the upgrade succeeded.
    # TODO: Or, just compare the 'Current Version' with the 'Latest Version'?
    print_versions "$SHELLCHECK_TOOL_NAME" "$SHELLCHECK_CURRENT_VERSION" "$SHELLCHECK_BINARY_VERSION" "$SHELLCHECK_LATEST_VERSION"

    # Create git commit
    log_info "Here is the git diff:"
    git diff
    confirm_continue
    git commit -a -m "Bump devel-tool version ($SHELLCHECK_TOOL_NAME): $SHELLCHECK_CURRENT_VERSION -> $SHELLCHECK_LATEST_VERSION"
    log_info "Here is the git log:"
    git log
    confirm_continue
  fi
  log_info "  => The version is latest."

  # Do the same for sfmt as for sheckcheck above.
  # TODO: Refactor (DRY)
  log_info "Checking that the version of installed $SHFMT_TOOL_NAME is latest."
  if [[ "$SHFMT_CURRENT_VERSION" != "$SHFMT_LATEST_VERSION" ]]; then
    log_info "  => Latest version found."

    log_warn "Will you upgrade $SHFMT_TOOL_NAME from $SHFMT_CURRENT_VERSION to $SHFMT_LATEST_VERSION ?"
    confirm_continue

    if ! git diff --quiet; then
      log_err "Commit all changes before running this script."
      log_err "(Or, you can bump the devel-tool version without this script (manually).)"
      exit 1
    fi

    bump_shfmt_version

    print_versions "$SHFMT_TOOL_NAME" "$SHFMT_CURRENT_VERSION" "$SHFMT_BINARY_VERSION" "$SHFMT_LATEST_VERSION"

    log_info "Here is the git diff:"
    git diff
    confirm_continue
    git commit -a -m "Bump devel-tool version ($SHFMT_TOOL_NAME): $SHFMT_CURRENT_VERSION -> $SHFMT_LATEST_VERSION"
    log_info "Here is the git log:"
    git log
    confirm_continue
  fi
  log_info "  => The version is latest."

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
  # Reload common.sh to support for above change.
  # Note especially SHELLCHECK_CURRENT_VERSION and its effect on SHELLCHECK_URL.
  source "$(dirname "$0")/common.sh"

  # Install(Reinstall) the devel-tool
  install_shellcheck
  check_shellcheck_is_ready
}
bump_shfmt_version() {
  # Overwrite devel-tools versions
  local -r TARGET_FILE="${COMMON_SH_PATH}"
  overwrite_version_number_variable "$TARGET_FILE" "SHFMT_CURRENT_VERSION" "$SHFMT_CURRENT_VERSION" "$SHFMT_LATEST_VERSION"
  # Reload common.sh to support for above change.
  # Note especially SHFMT_CURRENT_VERSION and its effect on SHFMT_URL.
  source "$(dirname "$0")/common.sh"

  # Install(Reinstall) the devel-tool
  install_shfmt
  check_shfmt_is_ready
}

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

main
