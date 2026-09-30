# Building, testing and releasing

The workflow is driven by [`just`](https://github.com/casey/just) and mirrors the one of the
`isc-hei-typst-templates` monorepo, reduced to a single package. `just` alone lists the recipes.

## Toolchain

| Tool | Needed for |
|---|---|
| `typst` ≥ 0.14 | everything |
| `just` | the recipes below |
| `poppler` (`pdfinfo`, `pdftoppm`, `pdftotext`) | tests and `tools/compare-exam.sh` |
| ImageMagick 7 (`magick`) | the side-by-side comparison PNGs |
| `pngquant`, `zopflipng` (`zopfli`) | the Universe thumbnail |
| [`typst-package-check`](https://github.com/typst/package-check) | `just universe-check` |
| Fonts: Source Sans 3 (or Source Sans Pro) | the body font; DejaVu Sans Mono ships with Typst |

macOS: `brew install typst just poppler imagemagick pngquant zopfli`.

## Development loop

```bash
just dev                 # link @preview/isc-hei-exam:<version> → this checkout, compile, smoke-test
typst watch template/exam.typ
just compare-samples     # LaTeX (left) | Typst (right), page by page, in $TMPDIR/isc-exam-compare
```

`just dev` creates a symlink in `~/Library/Application Support/typst/packages/preview/isc-hei-exam/<version>`
(`$XDG_DATA_HOME/typst/...` on Linux), so any document importing
`@preview/isc-hei-exam:<version>` uses the live source. In this mode the whole repository is visible
to Typst; `just check-pack` is what proves nothing leaks into the bundle.

### Calibrating against LaTeX

The reference is the LaTeX output, never the other way round. The loop, from the `latex-to-typst`
method: change **one** knob in `lib/settings.typ`, `just compare …`, look at the `compare-NN.png`,
repeat. Every knob carries its LaTeX origin in a comment; colours were sampled on the LaTeX PDFs,
not computed from the xcolor expressions.

`tools/compare-exam.sh <exam.typ> <reference.pdf> [reference-sol.pdf]` compiles the Typst document
in both modes, rasterises everything, writes the montages, compares page counts (exit code 2 on
mismatch) and diffs a structural fingerprint per page (question headings, margin points, totals).
`RMSE=1` adds a per-page pixel metric, useful to spot a regression between two iterations.

## Tests

```bash
just test        # typst init from @preview, compile exam + series × student/solutions, check page counts
just check-pack  # the bundle contains exactly the files of scripts/template-files
just test-all    # pack → check-pack → test, then restore the dev symlink
```

The expected page counts live in `tests/expected-pages.txt`; the LaTeX PDFs they come from are in
`tests/reference/`. CI (`.github/workflows/ci.yml`) runs the same steps on Ubuntu and uploads the
PDFs and comparison montages as artefacts.

## Releasing to the Typst Universe

Published versions are immutable, so bump first:

```bash
just bump-version            # patch; or `minor`, or an explicit X.Y.Z
just test-all
just universe-stage          # sparse-clone the fork, branch isc-hei-exam-<version> on upstream/main,
                             # pack into packages/preview/isc-hei-exam/<version>, typst-package-check, commit
just universe-push           # push to the fork and print the PR compare URL (the only networked write)
```

Write the PR description yourself (the `typst/packages` template asks whether it is a new package or
an update). To fix an **open** PR at the same version, `just update-pr` re-stages and force-pushes
over the branch. After the merge, `just uninstall` removes the local copy so the registry package is
used, and a fresh `typst init @preview/isc-hei-exam` must compile untouched.

The fork clone defaults to `~/git/typst-packages` (`UNIVERSE_CLONE=… just universe-stage` to change)
and is shared with the other `isc-hei-*` packages; branch names never collide.
