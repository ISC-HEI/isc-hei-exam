# Changelog

# v0.1.0, October 2026

First release: a Typst port of the ISC LaTeX exam template (Philip Hirschhorn's `exam.cls` plus the ISC `options.tex`), calibrated page for page against the LaTeX renders of the two sample documents and of a real 14-page CS101 exam.

## Added
- **`isc-exam()` show rule** with `kind: "exam" | "series"`, the exam geometry (two-sided, binding offset, alternating running headers and footers, "The end" on the last page) and the series geometry.
- **Cover page**: page-anchored ISC logo and name fields, ruled small-caps title block, `title-box` with the instructions, the grade table and the "This exam has N questions…" sentence, tiny revision line.
- **Question tree**: `question`, `part`, `subpart` and their `bonus-` variants as flat calls, points in the left margin (`[4 Pt]`, `[2 Bo]`), totals in the question headings and in the grade table computed from the document with `query()`, `half` points.
- **Answer spaces**: `solution`, `solution-or-dotted-lines`, `solution-or-lines`, `solution-or-box`, `fill-with-dotted-lines`, `fill-with-lines`, `answer-line`, with `1fr` for LaTeX's `\fill`.
- **Choices**: `checkboxes`, `inline-checkboxes`, `correct-choice`, `true-false` rows with the dashed hairlines.
- **Listings**: framed, numbered code blocks in the `listings` + `mdframed` look, the `options.tex` colour palette as a `.tmTheme`, `small-listing`, `verbatim`, `visible-spaces`, `doclisting`, `real-verb`.
- **Helpers**: `title-box`, `remark-box`, `leerseite`, `last-page`, `turn-page`, `turn-warning`, `new-page`, `line-sep`, `todo`, `colored`, `big-o`, `visible-space`, `warning-sign`.
- **Student and solution output from one source**: `typst compile --input solutions=true`, or `solutions: true`.
- UI strings in French (reproducing the LaTeX template's mix), English and German; `extra-i18n` overrides.
- `tools/compare-exam.sh`: side-by-side pages of a Typst exam and its LaTeX reference PDF, with page-count and question-structure checks.
