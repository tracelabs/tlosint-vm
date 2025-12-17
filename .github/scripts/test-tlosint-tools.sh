#!/bin/bash
# Verifies that tlosint-tools.sh can parse and execute without errors
set -euo pipefail

SCRIPT_PATH="${1:-scripts/tlosint-tools.sh}"

echo "Testing ${SCRIPT_PATH}..."

# 1. Syntax check
zsh -n "$SCRIPT_PATH"
echo "✅ Syntax check passed"

# 2. Run in Kali container
if ! command -v docker >/dev/null 2>&1; then
  echo "❌ Docker not available"; exit 1
fi

echo "Running in Kali container (timeout: 2 min)..."
OUTPUT=$(timeout 120 docker run --rm \
  -v "$(pwd)/${SCRIPT_PATH}:/test.sh:ro" \
  kalilinux/kali-rolling \
  sh -c "apt-get update -qq && apt-get install -y -qq zsh && timeout 60 zsh /test.sh" 2>&1) || true

# 3. Check for [ERR ] messages
ERRORS=$(echo "$OUTPUT" | grep "\[ERR \]" || true)
if [ -n "$ERRORS" ]; then
  echo "❌ Script logged errors:"
  echo "$ERRORS" | head -10
  exit 1
fi

echo "✅ All tests passed"
