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

# --- Tests for print_os_name() ---

@test "print_os_name: OS_ID=ubuntu outputs 'Ubuntu'" {
  OS_ID="ubuntu"
  run print_os_name
  [ "$status" -eq 0 ]
  [ "$output" = "OS NAME       : Ubuntu" ]
}

@test "print_os_name: OS_ID=archlinux outputs 'Arch Linux'" {
  OS_ID="archlinux"
  run print_os_name
  [ "$status" -eq 0 ]
  [ "$output" = "OS NAME       : Arch Linux" ]
}

# --- Tests for print_virtualization() ---

@test "print_virtualization: VIRTUALIZATION_ID=physical outputs 'Physical'" {
  VIRTUALIZATION_ID="physical"
  run print_virtualization
  [ "$status" -eq 0 ]
  [ "$output" = "VIRTUALIZATION: Physical" ]
}

@test "print_virtualization: VIRTUALIZATION_ID=docker outputs 'Docker'" {
  VIRTUALIZATION_ID="docker"
  run print_virtualization
  [ "$status" -eq 0 ]
  [ "$output" = "VIRTUALIZATION: Docker" ]
}

# --- Tests for print_current_shell() ---

@test "print_current_shell: CURRENT_SHELL_ID=bash outputs 'Bash'" {
  CURRENT_SHELL_ID="bash"
  run print_current_shell
  [ "$status" -eq 0 ]
  [ "$output" = "CURRENT SHELL : Bash" ]
}

@test "print_current_shell: CURRENT_SHELL_ID=zsh outputs 'Zsh'" {
  CURRENT_SHELL_ID="zsh"
  run print_current_shell
  [ "$status" -eq 0 ]
  [ "$output" = "CURRENT SHELL : Zsh" ]
}

# --- Tests for print_cpu_arch() ---

@test "print_cpu_arch: UNAME_CACHE_MACHINE=x86_64 outputs 'x86_64'" {
  UNAME_CACHE_MACHINE="x86_64"
  run print_cpu_arch
  [ "$status" -eq 0 ]
  [ "$output" = "CPU ARCH      : x86_64" ]
}

@test "print_cpu_arch: UNAME_CACHE_MACHINE=aarch64 outputs 'aarch64'" {
  UNAME_CACHE_MACHINE="aarch64"
  run print_cpu_arch
  [ "$status" -eq 0 ]
  [ "$output" = "CPU ARCH      : aarch64" ]
}
