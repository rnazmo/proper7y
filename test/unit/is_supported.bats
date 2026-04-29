#!/usr/bin/env bats

# TL;DR (What is this?):
#   Unit tests for the is_supported() function in proper7y.
#
# How to run:
#   ./devel-tools/bin/bats test/unit/
#   (or: make unit-tests)
#
# NOTE:
#   is_supported() is defined in proper7y and sourced here for testing.
#   To avoid running proper7y's init() and main() on source, we stub them out.

# Stub out functions that would run on source and cause side effects.
init() { :; }
main() { :; }

# Load the script under test.
# shellcheck source=../../proper7y
source "${BATS_TEST_DIRNAME}/../../proper7y"

# --- Tests for is_supported() ---

@test "returns 0 when the value is in the array" {
  run is_supported "ubuntu" "archlinux" "ubuntu" "debian"
  [ "$status" -eq 0 ]
}

@test "returns 1 when the value is not in the array" {
  run is_supported "fedora" "archlinux" "ubuntu" "debian"
  [ "$status" -eq 1 ]
}

@test "returns 0 when the array has only one element and it matches" {
  run is_supported "bash" "bash"
  [ "$status" -eq 0 ]
}

@test "returns 1 when the array has only one element and it does not match" {
  run is_supported "zsh" "bash"
  [ "$status" -eq 1 ]
}

@test "returns 1 when the array is empty" {
  run is_supported "ubuntu"
  [ "$status" -eq 1 ]
}

@test "does not match partial strings" {
  run is_supported "ubunt" "archlinux" "ubuntu" "debian"
  [ "$status" -eq 1 ]
}

@test "does not match superstrings" {
  run is_supported "ubuntu-lts" "archlinux" "ubuntu" "debian"
  [ "$status" -eq 1 ]
}
