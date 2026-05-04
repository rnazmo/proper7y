#!/usr/bin/env bats

# TL;DR (What is this?):
#   Unit tests for string formatting functions in proper7y:
#   pad_with_spaces() and print_row().
#
# How to run:
#   ./devel-tools/bin/bats test/unit/
#   (or: make unit-tests)

setup() {
  # shellcheck source=../../proper7y
  source "${BATS_TEST_DIRNAME}/../../proper7y"
}

# --- Tests for pad_with_spaces() ---

@test "pad_with_spaces: short string is right-padded to 14 characters" {
  result="$(pad_with_spaces "hello")"
  [ "${#result}" -eq 14 ]
}

@test "pad_with_spaces: short string has correct content with trailing spaces" {
  result="$(pad_with_spaces "hello")"
  [ "$result" = "hello         " ]
}

@test "pad_with_spaces: exactly 14-character string is unchanged" {
  result="$(pad_with_spaces "12345678901234")"
  [ "$result" = "12345678901234" ]
}

@test "pad_with_spaces: string longer than 14 characters is not truncated" {
  result="$(pad_with_spaces "123456789012345")"
  [ "${#result}" -eq 15 ]
}

@test "pad_with_spaces: empty string becomes 14 spaces" {
  result="$(pad_with_spaces "")"
  [ "${#result}" -eq 14 ]
}

# --- Tests for print_row() ---

@test "print_row: field name is padded to 14 chars followed by colon, space, and value" {
  run print_row "OS NAME" "Ubuntu"
  [ "$status" -eq 0 ]
  [ "$output" = "OS NAME       : Ubuntu" ]
}

@test "print_row: exactly 14-character field name is not padded further" {
  run print_row "12345678901234" "value"
  [ "$status" -eq 0 ]
  [ "$output" = "12345678901234: value" ]
}

@test "print_row: empty value is printed as empty string after separator" {
  run print_row "OS NAME" ""
  [ "$status" -eq 0 ]
  [ "$output" = "OS NAME       : " ]
}
