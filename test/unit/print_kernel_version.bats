#!/usr/bin/env bats

# TL;DR (What is this?):
#   Unit tests for print_kernel_version() in proper7y.
#
# How to run:
#   ./devel-tools/bin/bats test/unit/
#   (or: make unit-tests)

setup() {
  # shellcheck source=../../proper7y
  source "${BATS_TEST_DIRNAME}/../../proper7y"
}

# --- Tests for print_kernel_version() ---

@test "print_kernel_version: outputs kernel version on Linux" {
  UNAME_CACHE_KERNEL_NAME="linux"
  UNAME_CACHE_RELEASE="6.1.0-1-amd64"
  run print_kernel_version
  [ "$status" -eq 0 ]
  [ "$output" = "KERNEL VERSION: 6.1.0-1-amd64" ]
}

@test "print_kernel_version: outputs nothing on non-Linux (darwin)" {
  UNAME_CACHE_KERNEL_NAME="darwin"
  run print_kernel_version
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "print_kernel_version: outputs nothing on non-Linux (freebsd)" {
  UNAME_CACHE_KERNEL_NAME="freebsd"
  run print_kernel_version
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
