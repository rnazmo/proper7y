#!/bin/bash
set -eu

# Tl;DR (What is this?)
#   Check that the versions of the devel-tools are latest.

# TODO: Make sure that the version number shown by the binaries("/devel-tools/bin/*") also matches.
#   Cehck&Compare following three versions.
#     1. The versions written in the /devel-tools/script/common.sh (current version 1)
#     2. The version by the binary under /devel-tools/bin (current version 2)
#     3. The version in the GitHub latest release page URL (latest version)

source "$(dirname "$0")/common.sh"

main() {
  log_info "Start checking..."
  log_info "(This takes a few seconds. Wait a few seconds....)"

  local TOOL_NAME="shellcheck"
  local OWNER="koalaman"
  local REPO="shellcheck"
  check_for_update "$TOOL_NAME" "$OWNER" "$REPO" "$SHELLCHECK_VERSION"

  local TOOL_NAME="shfmt"
  local OWNER="mvdan"
  local REPO="sh"
  check_for_update "$TOOL_NAME" "$OWNER" "$REPO" "$SHFMT_VERSION"

  log_info "Checked all devel-tools!"
}

check_for_update() {
  local -r TOOL_NAME="$1"
  local -r OWNER="$2"
  local -r REPO="$3"
  local -r TOOL_CURRENT_VERSION="$4"

  TOOL_LATEST_VERSION="$(get_latest_version_number "$OWNER" "$REPO")"

  log_info "  $TOOL_NAME:"
  log_info "    current: $TOOL_CURRENT_VERSION"
  log_info "    latest : $TOOL_LATEST_VERSION"
  if [[ "$TOOL_CURRENT_VERSION" == "$TOOL_LATEST_VERSION" ]]; then
    log_info "    => The version is latest"
  else
    log_info "    => Latest version found"
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
  # TODO: Should I valodate the LATEST_VER ? (The format is like "v0.0.0"?)
  echo "$LATEST_VER"
}

main
