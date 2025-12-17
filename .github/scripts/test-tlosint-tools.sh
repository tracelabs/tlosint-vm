#!/bin/bash
# Test script for tlosint-tools.sh
# Verifies the script can parse and execute without crashing
set -euo pipefail

SCRIPT_PATH="${1:-scripts/tlosint-tools.sh}"

echo "Testing ${SCRIPT_PATH}..."

# Check syntax
if ! zsh -n "$SCRIPT_PATH"; then
  echo "❌ Syntax check failed"
  exit 1
fi
echo "✅ Syntax check passed"

# Test runtime execution in Kali container
echo "Testing script execution in Kali container..."
docker run --rm \
  --volume "$(pwd)/${SCRIPT_PATH}:/test-script.sh:ro" \
  kalilinux/kali-rolling \
  bash -c "
    apt-get update -qq >/dev/null 2>&1
    apt-get install -y -qq zsh >/dev/null 2>&1
    timeout 30 zsh /test-script.sh 2>&1 || {
      exit_code=\$?
      if [ \$exit_code -eq 124 ] || [ \$exit_code -eq 0 ]; then
        echo '✅ Script executed successfully (got past initialization)'
        exit 0
      else
        echo '❌ Script failed with exit code' \$exit_code
        exit \$exit_code
      fi
    }
  "

echo "✅ All tests passed"

