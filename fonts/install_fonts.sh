#!/usr/bin/env bash
# Install the fonts used by isc-hei-exam for a local `typst` (the web app has them).
# Same bundle as the other ISC Typst repositories: Source Sans 3 and Source Sans Pro
# (the name the Typst web editor uses), plus Fira Code, Inria Sans and the math
# fonts of the report templates. All of them are under the SIL Open Font License
# (see ofl.md). Code listings use DejaVu Sans Mono, which ships with Typst.
#
#   bash fonts/install_fonts.sh      (Linux and macOS)
set -u

RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'; VU="${GREEN}✔${NC}"

FONTS_URL="https://files.isc-vs.ch/typst/modern-isc-fonts-v2.tar.gz"
FONTS_ARCHIVE="modern-isc-fonts-v2.tar.gz"
FONTS_DIR="modern-isc-fonts-v2"

case "$(uname -s)" in
  Darwin) fonts_dir="${HOME}/Library/Fonts" ;;
  *)      fonts_dir="${HOME}/.local/share/fonts" ;;
esac

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cd "$work"

echo -e "Downloading and installing fonts into ${fonts_dir}..."
mkdir -p "${fonts_dir}" && echo -e "Fonts directory ready $VU"

if command -v curl >/dev/null; then
  curl -fsSL -o "${FONTS_ARCHIVE}" "${FONTS_URL}"
else
  wget -q "${FONTS_URL}" -O "${FONTS_ARCHIVE}"
fi
if [ $? -ne 0 ]; then
  echo -e "${RED}Error: failed to download ${FONTS_URL}${NC}"; exit 1
fi
echo -e "Font bundle downloaded $VU"

tar -zxf "${FONTS_ARCHIVE}"
cp "${FONTS_DIR}"/*.ttf "${FONTS_DIR}"/*.otf "${fonts_dir}/"
echo -e "Fonts installed $VU"

if command -v fc-cache >/dev/null; then
  fc-cache -f >/dev/null && echo -e "Font cache rebuilt $VU"
fi

# Verify that typst sees the fonts the exam template needs.
if command -v typst >/dev/null; then
  missing=()
  for font in "Source Sans 3" "Source Sans Pro"; do
    typst fonts | grep -q "^${font}$" || missing+=("$font")
  done
  if [ ${#missing[@]} -eq 0 ]; then
    echo -e "${VU} Source Sans 3 and Source Sans Pro are visible to typst. Install successful!"
  else
    echo -e "${RED}Not found by typst: ${missing[*]}${NC}"; exit 1
  fi
else
  echo "typst is not on the PATH; run 'typst fonts' later to check for Source Sans 3."
fi
