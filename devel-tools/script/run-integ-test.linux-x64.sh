#!/bin/bash
set -eu

# TL;DR (What is this?):
#   - Install and run stable 'property'.

URL="https://raw.githubusercontent.com/rnazmo/property/main/install.sh"

main() {
  echo "INFO : Start running integ-test (Install and run stable 'property')"

  echo "INFO : Cd to temp directory"
  cd "$(mktemp -d)"
  echo "INFO : pwd: $(pwd)"

  echo "INFO : Get the 'install.sh'"
  curl -O "$URL"
  chmod +x ./install.sh

  echo "INFO : Run the 'install.sh' and install property"
  ./install.sh .

  echo "INFO : Run property"
  ./property

  echo "INFO : Running integ-test successflly!"
}

main
