#!/bin/bash
set -eu

# Tl;DR (What is this?)
#   Print following three versions of the devel-tools:
#     'Current version': The expected version written in the `/devel-tools/script/common.sh`.
#     'Binary version' : The actual version shown by the binaries under `/devel-tools/bin/`.
#     'Latest version' : The latest version shown by the GitHub latest release page URL

source "$(dirname "$0")/common.sh"

main() {
  log_info "Start checking..."
  log_info "(This takes a few seconds. Wait a few seconds....)"

  local TOOL_NAME="shellcheck"
  local OWNER="koalaman"
  local REPO="shellcheck"
  print_versions "$TOOL_NAME" "$OWNER" "$REPO" "$SHELLCHECK_CURRENT_VERSION" "$SHELLCHECK_BINARY_VERSION"

  local TOOL_NAME="shfmt"
  local OWNER="mvdan"
  local REPO="sh"
  print_versions "$TOOL_NAME" "$OWNER" "$REPO" "$SHFMT_CURRENT_VERSION" "$SHFMT_BINARY_VERSION"

  log_info "Checked all devel-tools!"
}

print_versions() {
  local -r TOOL_NAME="$1"
  local -r OWNER="$2"
  local -r REPO="$3"
  local -r TOOL_CURRENT_VERSION="$4"
  local -r TOOL_BINARY_VERSION="$5"

  # Get the latest version number.
  TOOL_LATEST_VERSION="$(get_latest_version_number "$OWNER" "$REPO")"

  # Print info.
  log_info "  $TOOL_NAME:"
  log_info "    Current version: $TOOL_CURRENT_VERSION"
  log_info "    Binary version : $TOOL_BINARY_VERSION"
  log_info "    Latest version : $TOOL_LATEST_VERSION"

  # Compare the 'Binary Version' with the 'Current Version'.
  compare_binary_ver_with_current_ver_of_the_devel_tool "$TOOL_NAME" "$TOOL_BINARY_VERSION" "$TOOL_CURRENT_VERSION"

  # Compare the 'Current Version' with the 'Latest Version'.
  if [[ "$TOOL_CURRENT_VERSION" == "$TOOL_LATEST_VERSION" ]]; then
    log_warn "    => The version is latest"
  else
    log_warn "    => Latest version found"
  fi
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

main
