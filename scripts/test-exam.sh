#!/usr/bin/env bash
# Smoke test against the currently installed @preview package (dev symlink or
# packed): `typst init` a fresh project, compile the two starters in both modes,
# and assert the page counts recorded in tests/expected-pages.txt.
set -eu
. "$(dirname "${BASH_SOURCE[0]}")/setup"
cd "$ROOT"

rm -rf "tmp/$PKG_NAME"; mkdir -p tmp
( cd tmp && typst init "@preview/$PKG_NAME:$VERSION" >/dev/null )
cd "tmp/$PKG_NAME"

pages() { pdfinfo "$1" 2>/dev/null | awk '/^Pages:/ {print $2}'; }
fail=0
check() {  # <name> <src> [typst args...]
  local name="$1" src="$2"; shift 2
  typst compile "$@" "$src" "$name.pdf"
  local got want
  got="$(pages "$name.pdf")"
  want="$(awk -v n="$name" '$1 == n {print $2}' "$ROOT/tests/expected-pages.txt")"
  if [[ -n "$want" && "$got" != "$want" ]]; then
    echo "✗ $name: $got pages, expected $want"; fail=1
  else
    echo "✓ $name: $got pages"
  fi
}
check exam       exam.typ
check exam-sol   exam.typ   --input solutions=true
check series     series.typ
check series-sol series.typ --input solutions=true
exit $fail
