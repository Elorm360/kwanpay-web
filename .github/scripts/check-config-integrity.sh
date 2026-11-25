#!/usr/bin/env bash
# Guards build-time config files against hidden code.
#
# Background: postcss.config.mjs once carried an obfuscated loader appended
# after hundreds of spaces on the export line (see commit c27e9ba). Config
# files run on every dev/build, so they are a prime injection target. These
# files are short and hand-written: any very long line or dynamic-code
# primitive in them is treated as a failure.
set -euo pipefail

max_line=200
status=0

mapfile -t files < <(
  git ls-files \
    '*.config.js' '*.config.mjs' '*.config.cjs' '*.config.ts' '*.config.mts' \
    '.eslintrc*' 'babel.config.*' 'proxy.ts' 'middleware.ts' \
    ':!:node_modules/**' ':!:kwanpay_app/build/**'
)

for file in "${files[@]}"; do
  [ -f "$file" ] || continue

  long=$(awk -v max="$max_line" 'length($0) > max { print NR ": " length($0) " chars" }' "$file")
  if [ -n "$long" ]; then
    echo "::error file=$file::Line longer than $max_line characters (possible hidden code):"
    echo "$long"
    status=1
  fi

  trailing=$(grep -nE '[[:space:]]{40,}[^[:space:]]' "$file" || true)
  if [ -n "$trailing" ]; then
    echo "::error file=$file::Code hidden after a long run of whitespace:"
    echo "$trailing" | cut -c1-120
    status=1
  fi

  suspicious=$(grep -nE 'eval\(|new Function\(|\[.constructor.\]|global\[|globalThis\[|String\.fromCharCode|child_process|createRequire\(' "$file" || true)
  if [ -n "$suspicious" ]; then
    echo "::error file=$file::Dynamic-code primitive in a config file:"
    echo "$suspicious" | cut -c1-120
    status=1
  fi
done

if [ "$status" -eq 0 ]; then
  echo "Checked ${#files[@]} config files: no hidden code found."
fi
exit "$status"
