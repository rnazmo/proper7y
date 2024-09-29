#!/usr/bin/env bash
set -eu

# TL:DR (What is this?)
#   - Bump the version of proper7y (project).
#

source "$(dirname "$0")/common.sh"

readonly TARGETS=(
  "${PROJECT_ROOT}/proper7y"
  "${PROJECT_ROOT}/install.sh"
  "${COMMON_SH_PATH}"
)

readonly CURRENT_PROPER7Y_VERSION="$PROPER7Y_VERSION"

main() {
  log_info "Bump the project (= 'proper7y') version: START"

  if ! git diff --quiet; then
    # Check that tracked && (unstaged/staged) file changes not exist.
    log_err "Stage & push all changes to remote before running this script."
    log_err "(Or, you can bump the project version without this script (manually).)"
    exit 1
  elif ! git diff --quiet origin/main..HEAD; then
    # Check that all changes are pushed to remote.
    log_err "Push all changes to remote before running this script."
    log_err "(Or, you can bump the project version without this script (manually).)"
    exit 1
  fi

  rename_project_version
  log_info "Here is the git diff:"
  git diff
  confirm_continue

  git commit -a -m "Bump project version: $CURRENT_PROPER7Y_VERSION -> $NEW_PROPER7Y_VERSION"
  git tag "$NEW_PROPER7Y_VERSION"
  log_info "Here is the git log:"
  git log -n 3
  confirm_continue

  git push --atomic origin main "$NEW_PROPER7Y_VERSION"

  log_info "Bump the project (= 'proper7y') version: END"
}

rename_project_version() {
  log_info "CURRENT_PROPER7Y_VERSION: $CURRENT_PROPER7Y_VERSION"

  # Get a new version
  read -p "Enter NEW_PROPER7Y_VERSION: " -r NEW_PROPER7Y_VERSION
  # Validate the new version
  PATTERN='^v[0-9]+\.[0-9]+\.[0-9]+$'
  if ! [[ $NEW_PROPER7Y_VERSION =~ $PATTERN ]]; then
    log_err "Wrong value. Must follow this pattern: $PATTERN"
    log_err "'NEW_PROPER7Y_VERSION': $NEW_PROPER7Y_VERSION"
    return 1
  fi
  log_info "NEW_PROPER7Y_VERSION: $NEW_PROPER7Y_VERSION"

  # Overwrite the project version
  # TODO: This is DANGEROUS if project number (PROPER7Y_VERSION) and
  #       devel-tools versions (SHELLCHECK_CURRENT_VERSION or SHFMT_CURRENT_VERSION)
  #       match. Use 'overwrite_version_number_variable()' function.
  for TARGET in "${TARGETS[@]}"; do
    log_info "Overwrite the version in the target: START"
    log_info "TARGET: $TARGET"

    sed -i "s/${CURRENT_PROPER7Y_VERSION}/${NEW_PROPER7Y_VERSION}/" "$TARGET"

    log_info "Overwrite the version in the target: END"
  done

  return 0
}

main
