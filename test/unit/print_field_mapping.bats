#!/usr/bin/env bats

# TL;DR (What is this?):
#   Unit tests for simple field printing functions in proper7y:
#   print_os_name(), print_virtualization(), print_current_shell(), print_cpu_arch().
#
# How to run:
#   ./devel-tools/bin/bats test/unit/
#   (or: make unit-tests)

setup() {
  # shellcheck source=../../proper7y
  source "${BATS_TEST_DIRNAME}/../../proper7y"
}

# NOTE:
# Bats executes commands passed to `run` in a subshell.
# In Bash, associative arrays (declare -A) are NOT exported to subshells,
# so simply doing:
#
#   run print_os_name
#
# would fail because global mappings like OS_NAMES are empty in that context.
#
# Since this script uses `set -u` (nounset), accessing an unset array element
# (e.g. ${OS_NAMES[$OS_ID]}) causes an immediate exit with a non-zero status.
#
# To avoid this, we explicitly start a new Bash process and re-source the script
# inside it, ensuring that all global variables (including associative arrays)
# are properly initialized before calling the function under test.
#
# This pattern is required for any function that depends on global arrays.
#
# Example of the pattern:
#   BAD:
#     OS_ID="ubuntu"
#     run print_os_name
#   GOOD:
#     run bash -c '
#       source "'"${BATS_TEST_DIRNAME}"'/../../proper7y"
#       OS_ID="ubuntu"
#       print_os_name
#     '
#
# --- Tests for print_os_name() ---

@test "print_os_name: OS_ID=ubuntu outputs 'Ubuntu'" {
  run bash -c '
    source "'"${BATS_TEST_DIRNAME}"'/../../proper7y"
    OS_ID="ubuntu"
    print_os_name
  '
  [ "$status" -eq 0 ]
  [ "$output" = "OS NAME       : Ubuntu" ]
}

@test "print_os_name: OS_ID=archlinux outputs 'Arch Linux'" {
  run bash -c '
    source "'"${BATS_TEST_DIRNAME}"'/../../proper7y"
    OS_ID="archlinux"
    print_os_name
  '
  [ "$status" -eq 0 ]
  [ "$output" = "OS NAME       : Arch Linux" ]
}

# --- Tests for print_virtualization() ---

@test "print_virtualization: VIRTUALIZATION_ID=physical outputs 'Physical'" {
  run bash -c '
    source "'"${BATS_TEST_DIRNAME}"'/../../proper7y"
    VIRTUALIZATION_ID="physical"
    print_virtualization
  '
  [ "$status" -eq 0 ]
  [ "$output" = "VIRTUALIZATION: Physical" ]
}

@test "print_virtualization: VIRTUALIZATION_ID=docker outputs 'Docker'" {
  run bash -c '
    source "'"${BATS_TEST_DIRNAME}"'/../../proper7y"
    VIRTUALIZATION_ID="docker"
    print_virtualization
  '
  [ "$status" -eq 0 ]
  [ "$output" = "VIRTUALIZATION: Docker" ]
}

# --- Tests for print_chassis() ---

@test "print_chassis: CHASSIS_ID=desktop outputs 'Desktop'" {
  run bash -c '
    source "'"${BATS_TEST_DIRNAME}"'/../../proper7y"
    CHASSIS_ID="desktop"
    print_chassis
  '
  [ "$status" -eq 0 ]
  [ "$output" = "CHASSIS       : Desktop" ]
}

@test "print_chassis: CHASSIS_ID=laptop outputs 'Laptop'" {
  run bash -c '
    source "'"${BATS_TEST_DIRNAME}"'/../../proper7y"
    CHASSIS_ID="laptop"
    print_chassis
  '
  [ "$status" -eq 0 ]
  [ "$output" = "CHASSIS       : Laptop" ]
}

# --- Tests for print_current_shell() ---

@test "print_current_shell: CURRENT_SHELL_ID=bash outputs 'Bash'" {
  run bash -c '
    source "'"${BATS_TEST_DIRNAME}"'/../../proper7y"
    CURRENT_SHELL_ID="bash"
    print_current_shell
  '
  [ "$status" -eq 0 ]
  [ "$output" = "CURRENT SHELL : Bash" ]
}

@test "print_current_shell: CURRENT_SHELL_ID=zsh outputs 'Zsh'" {
  run bash -c '
    source "'"${BATS_TEST_DIRNAME}"'/../../proper7y"
    CURRENT_SHELL_ID="zsh"
    print_current_shell
  '
  [ "$status" -eq 0 ]
  [ "$output" = "CURRENT SHELL : Zsh" ]
}

# --- Tests for print_cpu_arch() ---

@test "print_cpu_arch: UNAME_CACHE_MACHINE=x86_64 outputs 'x86_64'" {
  # shellcheck disable=SC2034
  UNAME_CACHE_MACHINE="x86_64"
  run print_cpu_arch
  [ "$status" -eq 0 ]
  [ "$output" = "CPU ARCH      : x86_64" ]
}

@test "print_cpu_arch: UNAME_CACHE_MACHINE=aarch64 outputs 'aarch64'" {
  # shellcheck disable=SC2034
  UNAME_CACHE_MACHINE="aarch64"
  run print_cpu_arch
  [ "$status" -eq 0 ]
  [ "$output" = "CPU ARCH      : aarch64" ]
}

# --- Tests for print_kernel_version() ---

@test "print_kernel_version: UNAME_CACHE_RELEASE=6.1.0-1-amd64 outputs '6.1.0-1-amd64'" {
  # shellcheck disable=SC2034
  UNAME_CACHE_RELEASE="6.1.0-1-amd64"
  run print_kernel_version
  [ "$status" -eq 0 ]
  [ "$output" = "KERNEL VERSION: 6.1.0-1-amd64" ]
}

@test "print_kernel_version: UNAME_CACHE_RELEASE=7.0.3-arch1-2 outputs '7.0.3-arch1-2'" {
  # shellcheck disable=SC2034
  UNAME_CACHE_RELEASE="7.0.3-arch1-2"
  run print_kernel_version
  [ "$status" -eq 0 ]
  [ "$output" = "KERNEL VERSION: 7.0.3-arch1-2" ]
}
