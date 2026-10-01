root := justfile_directory()

# `just` (no args) prints this menu.
[private]
default:
	@just --list --unsorted

# ──────────────────────────────────────────────────────────────────────────────
# LOCAL DEVELOPMENT — @preview/isc-hei-exam points at this repo's live source.
# ──────────────────────────────────────────────────────────────────────────────

# ▶ link @preview to the live source, then compile the starters and run the smoke tests
[group('dev')]
dev: link test

# install the ISC font bundle (Source Sans 3, …) for the local typst
[group('dev')]
fonts:
	bash fonts/install_fonts.sh

# (re)link @preview/isc-hei-exam:<version> → this repository (self-heals after a pack)
[group('dev')]
link:
	./scripts/dev_link @preview

# compile template/*.typ in both modes → examples/*.pdf
[group('dev')]
compile-all:
	#!/usr/bin/env bash
	set -euo pipefail
	./scripts/show-pkg-mode
	mkdir -p examples
	typst compile template/exam.typ examples/exam.pdf
	typst compile --input solutions=true template/exam.typ examples/exam-sol.pdf
	typst compile template/series.typ examples/series.pdf
	typst compile --input solutions=true template/series.typ examples/series-sol.pdf
	ls -la examples/*.pdf

# smoke tests: typst init from @preview, compile 4 variants, check page counts
[group('dev')]
test:
	#!/usr/bin/env bash
	set -euo pipefail
	./scripts/show-pkg-mode
	./scripts/test-exam.sh

# ▶ side-by-side pages of a Typst exam vs its LaTeX reference PDF(s)
[group('dev')]
compare FILE REF REF_SOL="":
	./tools/compare-exam.sh "{{FILE}}" "{{REF}}" {{REF_SOL}}

# compare the two starters against the LaTeX references in tests/reference
[group('dev')]
compare-samples:
	./tools/compare-exam.sh template/exam.typ tests/reference/exam-sample.pdf tests/reference/exam-sample-sol.pdf
	./tools/compare-exam.sh template/series.typ tests/reference/serie-sample.pdf tests/reference/serie-sample-sol.pdf

# ──────────────────────────────────────────────────────────────────────────────
# PRE-RELEASE — build and check the artefact published to the Typst Universe.
# `pack` REPLACES the dev symlink; `just dev` restores it.
# ──────────────────────────────────────────────────────────────────────────────

# bump the version everywhere: patch (default) | minor | X.Y.Z, then relink
[group('pre-release')]
bump-version mode='patch': && link
	./scripts/bump-version "{{mode}}"

# render template/exam.typ page 1 → thumbnail.png (typst 120 ppi → pngquant → zopflipng)
[group('pre-release')]
generate-thumbs:
	#!/usr/bin/env bash
	set -euo pipefail
	typst compile template/exam.typ --pages 1 --format png --ppi 120 thumbnail.png
	command -v pngquant >/dev/null && pngquant --quality 50-80 thumbnail.png --ext .png --force
	if command -v zopflipng >/dev/null; then zopflipng -y thumbnail.png thumbnail.png.tmp && mv -f thumbnail.png.tmp thumbnail.png; fi
	ls -la thumbnail.png

# pack the real @preview artefact (auto-runs compile-all and generate-thumbs)
[group('pre-release')]
pack: compile-all generate-thumbs
	./scripts/pack @preview

# verify the package ships ONLY its required files (throwaway pack)
[group('pre-release')]
check-pack:
	./scripts/check-pack

# full pre-publish gate: pack → check-pack → test, then restore the dev symlink
[group('pre-release')]
test-all: pack check-pack test && link

# remove every local copy/symlink of the package from @preview
[group('pre-release')]
uninstall:
	./scripts/uninstall @preview

# ──────────────────────────────────────────────────────────────────────────────
# UNIVERSE — stage → (review) → push, then open the PR from the printed URL.
# ──────────────────────────────────────────────────────────────────────────────

# stage a release in the fork clone: branch on upstream/main, pack, validate, commit (no push)
[group('universe')]
universe-stage: compile-all generate-thumbs
	./scripts/universe-stage

# re-validate the staged package with typst-package-check
[group('universe')]
universe-check:
	./scripts/universe-check

# push the staged branch to the fork and print the PR compare URL
[group('universe')]
universe-push:
	./scripts/universe-push

# refresh an OPEN PR at the same version: re-stage and force-push over its branch
[group('universe')]
update-pr: universe-stage
	./scripts/universe-push --force
