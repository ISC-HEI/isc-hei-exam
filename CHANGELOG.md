# Changelog

# v0.1.0, October 2026

First release: a Typst port of the ISC LaTeX exam template (Philip Hirschhorn's `exam.cls` plus the ISC `options.tex`), calibrated page for page against the LaTeX renders of the two sample documents and of a real 14-page CS101 exam.

## Added
- **Marker style, as in exam.cls**: `#question[T]`, `#part(3)`, `#subpart` written without a body own the text that follows, up to the next marker; `#pagebreak()` works anywhere (the item continues on the next page); `#end-parts()` returns to the question level. The bracketed form stays available.
- Questions, parts and subparts are headings: PDF bookmarks and Tinymist's preview outline show the exam structure (`outline-depth`, default 3).
- **Short API**: `question[Title][intro]`, `part(3)[…]`, `answer(3cm)[…]` (`style: "lines" | "box"`, `blank: h`), `choices(correct[…], […])` with `inline: true`, `true-false(is-true[…], is-false[…])`. The exam.cls-named functions stay as aliases.
- A trailing `answer(1fr)` inside a part or subpart is hoisted out of its container, through nested levels, so it behaves like LaTeX's `\fill` glue.
- `short-answers(...)` (one subpart with an answer line per pair), `code-answer(code, output)` (the side-by-side loop layout), `part(title: ...)`, `question(intro: ...)`, and `expected-total:` on `isc-exam` (a red note on the cover when the points do not add up).
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
