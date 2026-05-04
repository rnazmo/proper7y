#!/usr/bin/env bats

# TL;DR (What is this?):
#   Unit tests for print_chassis() in proper7y.
#
# How to run:
#   ./devel-tools/bin/bats test/unit/
#   (or: make unit-tests)

setup() {
  # shellcheck source=../../proper7y
  source "${BATS_TEST_DIRNAME}/../../proper7y"
}

# --- Tests for print_chassis() ---

@test "print_chassis: CHASSIS_ID=n/a outputs 'N/A'" {
  CHASSIS_ID="n/a"
  run print_chassis
  [ "$status" -eq 0 ]
  [ "$output" = "CHASSIS       : N/A" ]
}

@test "print_chassis: CHASSIS_ID=laptop outputs 'Laptop'" {
  CHASSIS_ID="laptop"
  run print_chassis
  [ "$status" -eq 0 ]
  [ "$output" = "CHASSIS       : Laptop" ]
}

@test "print_chassis: CHASSIS_ID=desktop outputs 'Desktop'" {
  CHASSIS_ID="desktop"
  run print_chassis
  [ "$status" -eq 0 ]
  [ "$output" = "CHASSIS       : Desktop" ]
}

@test "print_chassis: CHASSIS_ID=unknown outputs 'Unknown'" {
  CHASSIS_ID="unknown"
  run print_chassis
  [ "$status" -eq 0 ]
  [ "$output" = "CHASSIS       : Unknown" ]
}

@test "print_chassis: unrecognized CHASSIS_ID is printed as-is" {
  CHASSIS_ID="some-future-type"
  run print_chassis
  [ "$status" -eq 0 ]
  [ "$output" = "CHASSIS       : some-future-type" ]
}
