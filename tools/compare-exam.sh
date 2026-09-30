#!/usr/bin/env bash
# compare-exam.sh — render a Typst exam next to its LaTeX reference, page by page.
#
#   tools/compare-exam.sh <exam.typ> <reference.pdf> [reference-sol.pdf] [out_dir]
#
# The reference PDFs are pre-existing LaTeX renders and are never rebuilt. The
# Typst source is compiled twice (student, and solutions with
# --input solutions=true when a solutions reference is given). Every page is
# rasterised and a side-by-side PNG is written (LaTeX left | Typst right):
#
#   <out_dir>/student/compare-NN.png      <out_dir>/solution/compare-NN.png
#
# Environment:
#   DPI=110        raster resolution
#   RMSE=1         also print a per-page RMSE table (coarse regression signal,
#                  not a parity metric: a one-line shift lights up the page)
#   DIFF=1         write diff-NN.png (red = differing pixels), implies RMSE=1
#   ROOT=<dir>     forwarded as `typst compile --root`
#
# Exit codes: 0 all good · 1 build failure / missing tool · 2 page-count mismatch.

set -u

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BOLD='\033[1m'; NC='\033[0m'
DPI="${DPI:-110}"
RMSE="${RMSE:-0}"
DIFF="${DIFF:-0}"
[ "$DIFF" = "1" ] && RMSE=1

usage() { sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }
[ $# -lt 2 ] && usage

TYP="$1"; REF="$2"; REF_SOL="${3:-}"
[ -f "$TYP" ] || { echo -e "${RED}error:${NC} no such file: $TYP"; exit 1; }
[ -f "$REF" ] || { echo -e "${RED}error:${NC} no such file: $REF"; exit 1; }
[ -n "$REF_SOL" ] && [ ! -f "$REF_SOL" ] && { echo -e "${RED}error:${NC} no such file: $REF_SOL"; exit 1; }

for t in typst pdftoppm pdfinfo pdftotext; do
  command -v "$t" >/dev/null || { echo -e "${RED}error:${NC} $t not found"; exit 1; }
done
HAVE_MAGICK=0; command -v magick >/dev/null && HAVE_MAGICK=1

BASE="$(basename "${TYP%.typ}")"
OUT="${4:-${TMPDIR:-/tmp}/isc-exam-compare/$BASE}"
mkdir -p "$OUT"; OUT="$(cd "$OUT" && pwd -P)"   # absolute: we cd into the .typ's directory to compile
REF="$(cd "$(dirname "$REF")" && pwd -P)/$(basename "$REF")"
[ -n "$REF_SOL" ] && REF_SOL="$(cd "$(dirname "$REF_SOL")" && pwd -P)/$(basename "$REF_SOL")"
TYP_ABS="$(cd "$(dirname "$TYP")" && pwd -P)/$(basename "$TYP")"
ROOT_ARGS=(); [ -n "${ROOT:-}" ] && ROOT_ARGS=(--root "$ROOT")

status=0

compile_variant() {  # <variant dir> <reference pdf> <extra typst args...>
  local dir="$1" ref="$2"; shift 2
  mkdir -p "$dir"; rm -f "$dir"/*.png "$dir"/*.pdf "$dir"/*.txt
  cp "$ref" "$dir/latex.pdf"
  if ! (cd "$(dirname "$TYP_ABS")" && typst compile "${ROOT_ARGS[@]}" "$@" "$TYP_ABS" "$dir/typst.pdf" 2>"$dir/typst.log"); then
    echo -e "${RED}error:${NC} typst compile failed — see $dir/typst.log"; sed -n '1,30p' "$dir/typst.log"; return 1
  fi
  [ -s "$dir/typst.log" ] && { echo -e "${YELLOW}typst warnings:${NC}"; sed -n '1,15p' "$dir/typst.log"; }
  return 0
}

pages_of() { pdfinfo "$1" 2>/dev/null | awk '/^Pages:/ {print $2}'; }

# Structural fingerprint of one page: question headings, margin points, totals.
fingerprint() {  # <pdf> <page>
  pdftotext -f "$2" -l "$2" -layout "$1" - 2>/dev/null \
    | grep -oE 'Question( bonus)? [0-9]+|\[[0-9½]+ (Pt|Bo)\]|Total:.*|The end|SOLUTION' \
    | sed -E 's/[[:space:]]+/ /g' | tr '\n' ';'
}

compare_variant() {  # <variant dir> <label>
  local dir="$1" label="$2"
  local nl nt n
  nl="$(pages_of "$dir/latex.pdf")"; nt="$(pages_of "$dir/typst.pdf")"
  if [ "$nl" = "$nt" ]; then
    echo -e "${BOLD}$label${NC}  Pages: LaTeX $nl | Typst $nt ${GREEN}(identique)${NC}"
  else
    echo -e "${BOLD}$label${NC}  Pages: LaTeX $nl | Typst $nt ${RED}(différent)${NC}"; status=2
  fi
  pdftoppm -r "$DPI" -png "$dir/latex.pdf" "$dir/latex"
  pdftoppm -r "$DPI" -png "$dir/typst.pdf" "$dir/typst"
  n=$(( nl > nt ? nl : nt ))
  local w h
  for f in "$dir"/latex-*.png; do [ -f "$f" ] && { read -r w h < <(magick identify -format '%w %h' "$f" 2>/dev/null || echo "909 1286"); break; }; done
  local i p L T out fp_l fp_t rmse
  [ "$RMSE" = "1" ] && printf '  %-5s %-8s\n' page rmse > "$dir/rmse.txt"
  for ((i = 1; i <= n; i++)); do
    p=$(printf '%02d' "$i")
    L=$(ls "$dir"/latex-*"$i".png 2>/dev/null | grep -E "latex-0*$i\.png$" | head -1)
    T=$(ls "$dir"/typst-*"$i".png 2>/dev/null | grep -E "typst-0*$i\.png$" | head -1)
    out="$dir/compare-$p.png"
    if [ "$HAVE_MAGICK" = "1" ]; then
      [ -n "$L" ] || { L="$dir/blank.png"; magick -size "${w:-909}x${h:-1286}" xc:white "$L"; }
      [ -n "$T" ] || { T="$dir/blank.png"; magick -size "${w:-909}x${h:-1286}" xc:white "$T"; }
      magick "$L" "$T" +append -bordercolor gray -border 2 "$out"
      if [ "$RMSE" = "1" ] && [ "$L" != "$dir/blank.png" ] && [ "$T" != "$dir/blank.png" ]; then
        rmse=$(magick compare -metric RMSE "$L" "$T" null: 2>&1 | sed -E 's/.*\(([0-9.]+)\).*/\1/')
        printf '  %-5s %-8s\n' "$p" "$rmse" >> "$dir/rmse.txt"
        [ "$DIFF" = "1" ] && magick compare "$L" "$T" -compose src "$dir/diff-$p.png" 2>/dev/null
      fi
    fi
    # structural check
    fp_l="$(fingerprint "$dir/latex.pdf" "$i")"; fp_t="$(fingerprint "$dir/typst.pdf" "$i")"
    if [ "$fp_l" != "$fp_t" ]; then
      echo -e "  p$p ${YELLOW}structure differs${NC}"
      echo "     LaTeX: ${fp_l:-—}"
      echo "     Typst: ${fp_t:-—}"
    fi
  done
  [ "$RMSE" = "1" ] && cat "$dir/rmse.txt"
  echo "  → $dir/compare-NN.png"
}

echo -e "${BOLD}isc-hei-exam · compare${NC}  $TYP  vs  $REF"
compile_variant "$OUT/student" "$REF" || exit 1
compare_variant "$OUT/student" "student "
if [ -n "$REF_SOL" ]; then
  compile_variant "$OUT/solution" "$REF_SOL" --input solutions=true || exit 1
  compare_variant "$OUT/solution" "solution"
fi
exit $status
