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
  echo "INFO : Bump the project (= 'property') version: START"

  # Check that all changes are pushed to remote.
  if ! git diff --quiet origin/main..HEAD; then
    echo "ERROR: Push all changes to remote before running this script."
    echo "       (Or, you can bump the project version without this script (manually).)"
    exit 1
  fi

  rename_project_version

  echo "INFO : Here is the git diff:"
  git diff
  confirm_continue

  git commit -a -m "Bump a version to $NEW_PROPERTY_VERSION"
  git tag "$NEW_PROPERTY_VERSION"
  echo "INFO : Here is the git log:"
  git log
  confirm_continue

  git push --atomic origin main "$NEW_PROPERTY_VERSION"

  echo "INFO : Bump the project (= 'property') version: END"
}

rename_project_version() {
  local CURRENT_PROPERTY_VERSION="$PROPERTY_VERSION"
  echo "INFO : CURRENT_PROPERTY_VERSION: $CURRENT_PROPERTY_VERSION"

  # Get a new version
  read -p "Enter NEW_PROPERTY_VERSION: " -r NEW_PROPERTY_VERSION
  # Validate the new version
  PATTERN='^v[0-9]+\.[0-9]+\.[0-9]+$'
  if ! [[ $NEW_PROPERTY_VERSION =~ $PATTERN ]]; then
    echo "ERROR: Wrong value. Must follow this pattern: $PATTERN"
    echo "       'NEW_PROPERTY_VERSION': $NEW_PROPERTY_VERSION"
    exit 1
  fi
  echo "INFO : NEW_PROPERTY_VERSION: $NEW_PROPERTY_VERSION"

  # Overwrite the project version
  for TARGET in "${TARGETS[@]}"; do
    echo "INFO : Overwrite the version in the target: START"
    echo "INFO : TARGET: $TARGET"

    sed -i "s/${CURRENT_PROPERTY_VERSION}/${NEW_PROPERTY_VERSION}/" "$TARGET"

    echo "INFO : Overwrite the version in the target: END"
  done
}

main
