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

echo "INFO : Start installing..."

VERSION="v0.0.1"

SRC_URL="https://raw.githubusercontent.com/rnazmo/property/${VERSION}/property"

print_usage() {
  echo "Usage: "
  echo "  ./install.sh <dir_path>"
  echo "  The <dir_path> is a directory where you want to install 'property' command."
  echo "Example: "
  echo "  ./install.sh ~/bin/"
}

# Check if the number of arguments is one.
if [ $# -eq 0 ]; then
  echo "ERROR: Too less arguments."
  print_usage
  exit 1
elif [ $# -gt 1 ]; then
  echo "ERROR: Too many arguments."
  print_usage
  exit 1
fi

DEST_DIR="$1"

if [ -d "$DEST_DIR" ]; then
  :
elif [ -e "$DEST_DIR" ]; then
  echo "ERROR: The path $DEST_DIR is not a directory. Must be a directory"
  print_usage
  exit1
else
  echo "INFO : The path $DEST_DIR does not exist. Creating..."
  mkdir -p "$DEST_DIR"
  echo "INFO : The path created."
fi

echo "INFO : SRC_URL is $SRC_URL"
echo "INFO : DEST_DIR is $DEST_DIR"

cd "$DEST_DIR"

curl -O "$SRC_URL"

chmod +x ./property

if [ ! -x ./property ]; then
  echo "ERROR: Something wrong :("
  print_usage
  exit 1
fi

echo "INFO : Installed successflly!"
