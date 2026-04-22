#!/usr/bin/env bash
set -eu

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
# We check structure (headers, separator lines, field names) and
# the format of a few environment-independent fields.
# Checking that values are not "Unknown" is left as a future TODO,
# because it depends on the CI environment and is fragile.
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

  # Check field names exist
  assert_line_exists "$OUTPUT" "CURRENT DATE"
  assert_line_exists "$OUTPUT" "VIRTUALIZATION"
  assert_line_exists "$OUTPUT" "CPU ARCH"
  assert_line_exists "$OUTPUT" "OS NAME"
  assert_line_exists "$OUTPUT" "OS VERSION"
  assert_line_exists "$OUTPUT" "CURRENT SHELL"
  assert_line_exists "$OUTPUT" "BASH VERSION"

  # Check CURRENT DATE format (YYYY-MM-DD)
  if ! echo "$OUTPUT" | grep -qE "^CURRENT DATE\s+: [0-9]{4}-[0-9]{2}-[0-9]{2}$"; then
    log_err "CURRENT DATE does not match expected format YYYY-MM-DD"
    return 1
  fi

  # Check BASH VERSION format (X.Y.Z)
  if ! echo "$OUTPUT" | grep -qE "^BASH VERSION\s+: [0-9]+\.[0-9]+\.[0-9]+$"; then
    log_err "BASH VERSION does not match expected format X.Y.Z"
    return 1
  fi

  # Level 2: Check that field values are not "Unknown" or empty.
  # "Unknown" in any field indicates an identification failure, which is a bug
  # regardless of the environment.
  local -a LEVEL2_FIELDS=(
    "CURRENT DATE"
    "VIRTUALIZATION"
    "CPU ARCH"
    "OS NAME"
    "OS VERSION"
    "CURRENT SHELL"
    "BASH VERSION"
  )
  local FIELD
  for FIELD in "${LEVEL2_FIELDS[@]}"; do
    # Extract the value after the ': ' separator.
    local VALUE
    VALUE="$(echo "$OUTPUT" | grep -E "^${FIELD}\s+: " | sed 's/^[^:]*: //')"
    if [[ -z "$VALUE" ]]; then
      log_err "Field '${FIELD}' is missing or has an empty value ($VALUE)"
      return 1
    fi
    if [[ "$VALUE" == "Unknown" ]]; then
      log_err "Field '${FIELD}' has value 'Unknown', which indicates an identification failure ($VALUE)"
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
