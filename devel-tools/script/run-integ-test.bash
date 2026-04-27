#!/usr/bin/env bash
set -euo pipefail

# TL;DR (What is this?):
#   - Install and run stable 'proper7y'.
#
# Platform note:
#   This script does not depend on Linux/x64-specific tools,
#   and runs on both Linux and macOS. (Ref: ADR-012)
#   (Unlike the other devel-tools scripts, which are Linux/x64-only.)

source "$(dirname "$0")/common.bash"
initialize_global_variables

# Why we use the main branch URL (not a tagged version):
#   install.bash itself contains PROPER7Y_VERSION internally.
#   So running install.bash from main always installs the latest stable proper7y.
#   This means the entry point URL can stay fixed forever, regardless of version bumps.
readonly URL="https://raw.githubusercontent.com/rnazmo/proper7y/main/install.bash"

# Assert that the output of proper7y looks correct.
#
# Design:
#   Rather than hardcoding which fields appear in which environment,
#   this function splits fields into two categories:
#
#   - REQUIRED_FIELDS: Always present regardless of environment.
#     Checked for existence AND that the value is not empty or "Unknown".
#   - CONDITIONAL_FIELDS: Present only in certain environments (e.g. Linux-only).
#     If a conditional field appears in the output, its value is also checked.
#     If it does not appear, the absence is silently accepted.
#
#   This avoids duplicating proper7y's internal condition logic in test code.
#   When a new environment-dependent field is added to proper7y, only
#   CONDITIONAL_FIELDS needs to be updated here. See ADR-029.
assert_output() {
  local -r OUTPUT="$1"
  log_info "Asserting output..."

  # Check header line exists
  assert_line_exists "$OUTPUT" "proper7y v"

  # Check two separator lines exist
  local -r SEPARATOR_COUNT="$(echo "$OUTPUT" | grep -c "^============================================================$")"
  if [[ "$SEPARATOR_COUNT" -ne 2 ]]; then
    log_err "Expected 2 separator lines, but found: $SEPARATOR_COUNT"
    return 1
  fi

  # Fields that must always appear, regardless of environment.
  local -ar REQUIRED_FIELDS=(
    "CURRENT DATE"
    "VIRTUALIZATION"
    "CHASSIS"
    "CPU ARCH"
    "OS NAME"
    "OS VERSION"
    "CURRENT SHELL"
    "BASH VERSION"
  )

  # Fields that appear only in certain environments (e.g. Linux-only, Zsh-only).
  # If present in the output, their values are validated the same way as required fields.
  # If absent, the absence is silently accepted.
  local -ar CONDITIONAL_FIELDS=(
    "KERNEL VERSION" # Linux-only
    "ZSH VERSION"    # Zsh-only
  )

  # Check existence of all required fields.
  local FIELD
  for FIELD in "${REQUIRED_FIELDS[@]}"; do
    assert_line_exists "$OUTPUT" "$FIELD"
  done

  # Check CURRENT DATE format (YYYY-MM-DD)
  if ! echo "$OUTPUT" | grep -qE "^CURRENT DATE\s*: [0-9]{4}-[0-9]{2}-[0-9]{2}$"; then
    log_err "CURRENT DATE does not match expected format YYYY-MM-DD"
    return 1
  fi

  # Check BASH VERSION format (X.Y.Z)
  if ! echo "$OUTPUT" | grep -qE "^BASH VERSION\s*: [0-9]+\.[0-9]+\.[0-9]+$"; then
    log_err "BASH VERSION does not match expected format X.Y.Z"
    return 1
  fi

  # For all required fields and any conditional fields that appear in the output,
  # check that the value is not empty or "Unknown".
  # "Unknown" in any field indicates an identification failure, which is a bug.
  local -a FIELDS_TO_VALIDATE=("${REQUIRED_FIELDS[@]}")
  for FIELD in "${CONDITIONAL_FIELDS[@]}"; do
    if echo "$OUTPUT" | grep -qE "^${FIELD}\s*: "; then
      FIELDS_TO_VALIDATE+=("$FIELD")
    fi
  done

  for FIELD in "${FIELDS_TO_VALIDATE[@]}"; do
    local VALUE
    VALUE="$(echo "$OUTPUT" | grep -E "^${FIELD}\s*: " | sed 's/^[^:]*: //')"
    if [[ -z "$VALUE" ]]; then
      log_err "Field '${FIELD}' is missing or has an empty value"
      return 1
    fi
    if [[ "$VALUE" == "Unknown" ]]; then
      log_err "Field '${FIELD}' has value 'Unknown', which indicates an identification failure"
      return 1
    fi
  done

  log_info "Assert passed!"
}

# Assert that the output contains a line with the given pattern.
assert_line_exists() {
  local -r OUTPUT="$1"
  local -r PATTERN="$2"
  if ! echo "$OUTPUT" | grep -q "$PATTERN"; then
    log_err "Expected to find '$PATTERN' in output, but not found."
    return 1
  fi
}

main() {
  log_info "Start running integ-test (Install and run stable 'proper7y')"

  log_info "Cd to temp directory"
  local -r TEMP_DIR="$(mktemp -d)"
  trap 'rm -rf "${TEMP_DIR:-}"' EXIT # cleanup
  cd "$TEMP_DIR"
  log_info "TEMP_DIR: $TEMP_DIR"
  log_info "pwd: $(pwd)"

  log_info "Get the 'install.bash'"
  curl -O "$URL"
  chmod +x ./install.bash

  log_info "Run the 'install.bash' and install proper7y"
  ./install.bash .

  log_info "Run proper7y"
  local -r OUTPUT="$(./proper7y)"
  echo "$OUTPUT"
  assert_output "$OUTPUT"

  log_info "Running integ-test successfully!"
}

main

exit 0
