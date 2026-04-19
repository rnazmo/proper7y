#!/usr/bin/env bash
set -eu

# TL:DR (What is this?)
#   - Bump the version of proper7y (project).
#

source "$(dirname "$0")/common.bash"
initialize_global_variables

readonly TARGETS=(
  "${PROJECT_ROOT}/proper7y"
  "${PROJECT_ROOT}/install.bash"
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

  local -r NEW_PROPER7Y_VERSION="$(prompt_new_version)"
  overwrite_project_version "$NEW_PROPER7Y_VERSION"
  verify_version_consistency "$NEW_PROPER7Y_VERSION"
  log_info "Here is the git diff:"
  git diff
  confirm_continue

  git commit -a -m "chore: Bump project version: $CURRENT_PROPER7Y_VERSION -> $NEW_PROPER7Y_VERSION"
  git tag "$NEW_PROPER7Y_VERSION"
  log_info "Here is the git log:"
  git log -n 3
  confirm_continue

  git push --atomic origin main "$NEW_PROPER7Y_VERSION"

  log_info "Bump the project (= 'proper7y') version: END"
}

# Only perform version input and validation. Return the result to standard output.
prompt_new_version() {
  local new_version
  read -p "Enter NEW_PROPER7Y_VERSION: " -r new_version
  local -r PATTERN='^v[0-9]+\.[0-9]+\.[0-9]+$'
  if ! [[ $new_version =~ $PATTERN ]]; then
    log_err "Wrong value. Must follow this pattern: $PATTERN"
    return 1
  fi
  echo "$new_version"
}

overwrite_project_version() {
  local -r NEW_VERSION="$1"
  log_info "CURRENT_PROPER7Y_VERSION: $CURRENT_PROPER7Y_VERSION"
  log_info "NEW_PROPER7Y_VERSION    : $NEW_VERSION"
  for TARGET in "${TARGETS[@]}"; do
    overwrite_version_number_variable "$TARGET" "PROPER7Y_VERSION" "$CURRENT_PROPER7Y_VERSION" "$NEW_VERSION"
  done
}

main
