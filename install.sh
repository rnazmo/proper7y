#!/bin/bash
set -eu

# What is this:
#   Install latest version of 'property' command.
#
# Usage:
#   $ ./install.sh <dir_path>
#   The <dir_path> is a directory where you want to install 'property' command.
#
# Example:
#   $ ./install.sh ~/bin/
#
# If you want to download this script from remote and run it with one liner, run like:
#   $ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rnazmo/property/main/install.sh ${HOME}/bin/)"

PROPERTY_VERSION="v0.1.6"

SRC_URL="https://raw.githubusercontent.com/rnazmo/property/${PROPERTY_VERSION}/property"

parse_args() {
  # Parse argument:
  # Check if the number of arguments is one.
  if [ $# -eq 0 ]; then
    log_err "Too less arguments."
    print_usage
    exit 1
  elif [ $# -gt 1 ]; then
    log_err "Too many arguments."
    print_usage
    exit 1
  fi
  DEST_DIR="$1"

  # Validate argument:
  # Check if the DEST_DIR exists and is directory.
  if [ -d "$DEST_DIR" ]; then
    :
  elif [ -e "$DEST_DIR" ]; then
    log_err "The path $DEST_DIR is not a directory. Must be a directory"
    print_usage
    exit1
  else
    log_info "The path $DEST_DIR does not exist. Creating..."
    mkdir -p "$DEST_DIR"
    log_info "The path created."
  fi
}

main() {
  log_info "Start installing..."

  log_info "SRC_URL is $SRC_URL"
  log_info "DEST_DIR is $DEST_DIR"

  cd "$DEST_DIR"

  # Download the file from remote server.
  curl -O "$SRC_URL"

  # Add execute poermission.
  chmod +x ./property

  if [ ! -x ./property ]; then
    log_err "Something wrong :("
    print_usage
    exit 1
  fi

  log_info "Installed successflly!"
}

print_usage() {
  echo "Usage: "
  echo "  ./install.sh <dir_path>"
  echo "  The <dir_path> is a directory where you want to install 'property' command."
  echo "Example: "
  echo "  ./install.sh ~/bin/"
}

log_info() {
  local -r PREFIX="INFO :"
  echo "$PREFIX $1"
}
log_warn() {
  local -r PREFIX="WARN :"
  echo "$PREFIX $1"
}
log_err() {
  local -r PREFIX="ERROR:"
  echo "$PREFIX $1"
}

parse_args "$@"

main
