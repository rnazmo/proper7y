#!/bin/bash
set -eu

# TL:DR (What is this?)
#   - Bump the version of property (project).
#

source "$(dirname "$0")/common.sh"

TARGETS=(
  "${PROJECT_ROOT}/property"
  "${PROJECT_ROOT}/install.sh"
  "${PROJECT_ROOT}/devel-tools/script/common.sh"
)

main() {
  log_info "Bump the project (= 'property') version: START"

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

  git commit -a -m "Bump a version to $NEW_PROPERTY_VERSION"
  git tag "$NEW_PROPERTY_VERSION"
  log_info "Here is the git log:"
  git log
  confirm_continue

  git push --atomic origin main "$NEW_PROPERTY_VERSION"

  log_info "Bump the project (= 'property') version: END"
}

rename_project_version() {
  local -r CURRENT_PROPERTY_VERSION="$PROPERTY_VERSION"
  log_info "CURRENT_PROPERTY_VERSION: $CURRENT_PROPERTY_VERSION"

  # Get a new version
  read -p "Enter NEW_PROPERTY_VERSION: " -r NEW_PROPERTY_VERSION
  # Validate the new version
  PATTERN='^v[0-9]+\.[0-9]+\.[0-9]+$'
  if ! [[ $NEW_PROPERTY_VERSION =~ $PATTERN ]]; then
    log_err "Wrong value. Must follow this pattern: $PATTERN"
    log_err "'NEW_PROPERTY_VERSION': $NEW_PROPERTY_VERSION"
    exit 1
  fi
  log_info "NEW_PROPERTY_VERSION: $NEW_PROPERTY_VERSION"

  # Overwrite the project version
  for TARGET in "${TARGETS[@]}"; do
    log_info "Overwrite the version in the target: START"
    log_info "TARGET: $TARGET"

    sed -i "s/${CURRENT_PROPERTY_VERSION}/${NEW_PROPERTY_VERSION}/" "$TARGET"

    log_info "Overwrite the version in the target: END"
  done
}

main
