<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="https://raw.githubusercontent.com/ISC-HEI/isc-logos/main/white/ISC%20Logo%20inline%20white%20v3%20-%20large.webp">
  <img align="right" height="50" alt="ISC Logo"
       src="https://raw.githubusercontent.com/ISC-HEI/isc-logos/main/black/ISC%20Logo%20inline%20black%20v3%20-%20large.webp"/>
</picture>

[![CI](https://github.com/ISC-HEI/isc-hei-exam/actions/workflows/ci.yml/badge.svg)](https://github.com/ISC-HEI/isc-hei-exam/actions/workflows/ci.yml)
[![Typst Universe](https://img.shields.io/badge/Typst%20Universe-isc--hei--exam-239dad?logo=typst&logoColor=white)](https://typst.app/universe/package/isc-hei-exam)
[![License: MIT](https://img.shields.io/badge/license-MIT-brightgreen)](https://github.com/ISC-HEI/isc-hei-exam/blob/main/LICENSE)

# isc-hei-exam — written exams and exercise series

The [Typst](https://typst.app/) template for written exams and exercise series of the [ISC degree programme](https://isc.hevs.ch/) at the School of Engineering in Sion. It is a one-to-one port of the ISC LaTeX exam template (Philip Hirschhorn's `exam` class plus the ISC `options.tex` used since 2009): same page geometry, same cover, same question numbering, points in the margin, grade table computed from the document, dotted answer spaces, MCQ and true/false rows, framed listings, and the same two PDFs out of one source: the exam handed to the students and the one with the solutions. The layout was calibrated page for page against the LaTeX renders, and a 14-page real exam comes out with the identical pagination.

## Preview

| Cover | Questions | Solutions |
|:---:|:---:|:---:|
| <a href="https://github.com/ISC-HEI/isc-hei-exam/blob/main/examples/exam.pdf?raw=true"><img src="thumbnail.png" width="230" alt="Cover of the sample exam"></a> | <a href="https://github.com/ISC-HEI/isc-hei-exam/blob/main/examples/exam.pdf?raw=true">exam.pdf</a> — 12 pages, the student version | <a href="https://github.com/ISC-HEI/isc-hei-exam/blob/main/examples/exam-sol.pdf?raw=true">exam-sol.pdf</a> — the same source with the answers |

The series flavour: [`series.pdf`](https://github.com/ISC-HEI/isc-hei-exam/blob/main/examples/series.pdf?raw=true) and [`series-sol.pdf`](https://github.com/ISC-HEI/isc-hei-exam/blob/main/examples/series-sol.pdf?raw=true).

## Features

- **Exams that count themselves** — points given to parts and subparts are summed into the question headings, the cover grade table and the total sentence, by `query()`, never by hand
- **One source, two PDFs** — `typst compile --input solutions=true` prints the solutions in framed boxes where the students get dotted lines, and nothing else moves
- **The exam.cls look** — two-sided geometry with a binding offset, date and small-caps title alternating in the running header, HES-SO logo and page numbers swapping sides, "The end" on the last page
- **Answer spaces** — dotted lines, ruled lines, empty boxes, answer lines, with `1fr` for LaTeX's `\fill`
- **Choices** — square checkboxes, inline or stacked, and true/false rows with the dashed hairlines
- **Listings** — grey rounded frames with line numbers outside, the IntelliJ-like palette of the LaTeX `listings` setup, small and unframed variants
- **Series mode** — `series.with(...)` switches to the exercise-series geometry, header and title block
- **Trilingual UI strings** — French (reproducing the historical template, English boilerplate included), English and German, overridable per document

## Quick Start

```bash
# In the Typst web app: start a new project from the isc-hei-exam template.
# Locally: create a project from the template …
typst init @preview/isc-hei-exam
cd isc-hei-exam

# … then compile the student version and the solutions
typst compile exam.typ
typst compile --input solutions=true exam.typ exam-sol.pdf

# A series works the same way
typst compile series.typ
```

The body font is **Source Sans 3** (the LaTeX template used its predecessor Source Sans Pro). It is available in the Typst web app; locally, install it once (Google Fonts, or your package manager) and check that `typst fonts` lists it. When it is missing, the document renders a single page telling you so instead of silently using another font; pass `check-fonts: false` to render anyway. Code uses DejaVu Sans Mono, which ships with Typst.

## Writing an exam

````typst
#import "@preview/isc-hei-exam:0.1.0": *

#show: isc-exam.with(
  title: [Test semestriel],
  course: [101.1 -- Programmation impérative],
  date: [29.1.2026], month: [Janvier 2026],
  teachers: [Dr P.-A. Mudry], revision: [Rev 1.0],
  expected-total: 6,
  instructions: [*Consigne :* Lisez attentivement la donnée …],
)

#question[Short questions]
Cette question est séparée en plusieurs exercices indépendants.

#part(3)
Qu'affiche le code suivant ?
```scala
println((1 to 3).sum)
```
#answer(2cm)[`6`]

#part(1)
Que vaut `true || !true` ? #choices(inline: true, correct[`true`], [`false`], [ça dépend])

#part(2)
_Vrai ou faux ?_
#true-false(
  is-true[`0 to 10` a 11 éléments],
  is-false[`Array(1) == Array(1)` vaut `true`],
)

#pagebreak()

#question[Récursivité]
#part(4)
Écrivez la fonction `fact`.
#answer(1fr)[```scala def fact(n: Int): Int = if (n <= 1) 1 else n * fact(n - 1)```]

#last-page()
````

As in exam.cls, `#question[…]`, `#part(3)` and `#subpart` are **markers**: what follows belongs to them, up to the next marker. There is nothing to close, and `#pagebreak()` works anywhere, the item simply continues on the next page. `#end-parts()` returns to the question level (`\end{parts}`), which is rarely needed. The bracketed form `#part(3)[…]` is still accepted when a body must be explicit.

The whole vocabulary fits in a few lines:

| | |
|---|---|
| `question[Title]`, `question(points: 3)[Title]` | a numbered question; the text that follows is its intro |
| `part(3)`, `subpart(1)`, `bonus-part(2)`, `bonus-subpart(1)` | `(a)`, `1)`, with `[3 Pt]` / `[2 Bo]` in the margin; `title:` for a bold first line |
| `answer(3cm)[solution]` | dotted lines for the students, the solution in a box for the teacher |
| `answer(h, style: "lines")`, `answer(h, style: "box")`, `answer(blank: h)` | ruled lines, an empty frame, nothing |
| `answer(1fr)[…]` | the rest of the page |
| `answer-line[Int]` | a short rule at the right, the answer written on it in the solutions |
| `choices(correct[…], […], […])`, `choices(inline: true, …)` | square boxes stacked, round boxes in the running text |
| `true-false(is-true[…], is-false[…])` | the True / False rows with their dashed rules |
| `solution[…]` | shown in the solutions only |
| `short-answers((`a + b`, [Int]), (`c / b`, [Short]))` | one subpart with an answer line per pair (`level: "part"` for parts) |
| `code-answer(```scala …```, [edb])` | code on the left, "Solution :" with a 3.5 cm answer area on the right, never split across pages |
| `part(3, title: [Partie 1])[…]` | a bold title on the first line of the part (`\subsection*` in the LaTeX exams) |
| `last-page()`, `leerseite()`, `turn-page()`, `new-page()` | "The end", a blank page, "Turn page →", a page break inside a part |

`isc-exam(expected-total: 45)` prints a red note on the cover when the points in the document do not add up to the announced total, and another one if a marker ended up inside a container (a `#part(3)` written inside brackets), where the library cannot see it.

A question with an intro and no title: `question(intro: [...])`. A part with no text of its own, `#part(4)` directly followed by `#subpart`, puts `(c)` and `1)` on one line like exam.cls. `half` gives ½ points: `part(2 + half)`.

An `answer(1fr)` written last in a part or subpart is hoisted out of its container by the library, through nested levels, so what follows on the same page still fits, like LaTeX's `\fill` glue. Elsewhere in a body, a `1fr` space fills the rest of the page and pushes what follows to the next one.

### From LaTeX to Typst

The exam.cls names are kept as aliases; both columns compile.

| exam.cls / options.tex | isc-hei-exam |
|---|---|
| `\def\withanswers{}` at build time | `--input solutions=true`, or `solutions: true` |
| `\def\exam{}` / the series preamble | `isc-exam.with(...)` / `series.with(...)` |
| `\thetitle`, `\examDate`, `\examMonth`, `\rev`, first-page footer | `title:`, `date:`, `month:`, `revision:`, `teachers:` |
| `\titlebox{...}` with the grade table | `instructions: [...]`, `grade-table: auto \| "simple" \| "combined" \| none` |
| `\titledquestion{T}[p]`, `\question` | `question[T]`, `question(points: p)[T]` |
| `\bonusquestion` | `bonus-question[T]` |
| `\part[p]`, `\bonuspart[p]`, `\subpart[p]`, `\bonussubpart[p]` | `part(p)`, `bonus-part(p)`, `subpart(p)`, `bonus-subpart(p)` (markers; `part(p)[...]` with an explicit body also works) |
| `\begin{parts}`, `\end{parts}` | nothing, `end-parts()` |
| `2\half` | `2 + half` |
| `\begin{solutionordottedlines}[h]`, `[\fill]` | `answer(h)[...]`, `answer(1fr)[...]` (alias `solution-or-dotted-lines`) |
| `\begin{solutionorlines}[h]`, `\begin{solutionorbox}[h]` | `answer(h, style: "lines")`, `answer(h, style: "box")` (aliases `solution-or-lines`, `solution-or-box`) |
| `\begin{solution}[h]` | `answer(blank: h)[...]` or `solution(height: h)[...]`; `solution[...]` with no space |
| `\fillwithdottedlines{h}`, `\fillwithlines{h}` | `fill-with-dotted-lines(h)`, `fill-with-lines(h)` |
| `\answerline[ans]`, `\answerlinelength` | `answer-line[ans]`, `answer-line-length:` |
| `\begin{checkboxes}` + `\choice` / `\correctchoice` | `choices([...], correct[...])` (aliases `checkboxes`, `correct-choice`) |
| `\begin{oneparcheckboxes}` | `choices(inline: true, ...)` (alias `inline-checkboxes`) |
| `\begintruefalse`, `\truefalse{s}{true}` | `true-false(is-true[s], is-false[s], ...)` (legacy `true-false[s][true]` per row still works) |
| `\begin{scala}`, `\begin{verbatim_lst}` | ```` ```scala ```` fenced block, fenced block without a language |
| `small_scala_frame`, `verbatim`, `verbatim_lst_spaces`, `doclisting`, `real_verb` | `small-listing[...]`, `verbatim[...]`, `visible-spaces[...]`, `doclisting[...]`, `real-verb("...", spaces: true)` |
| `\part[3] \subsection*{T}` | `part(3, title: [T])[...]` (or `== T` in the body) |
| `\remarkbox{...}`, `\titlebox{...}` | `remark-box[...]`, `title-box[...]` |
| `\leerseite`, `\lastPage` | `leerseite()`, `last-page()` |
| `\turnWarning`, `\turnpage`, `\lineSep` | `turn-warning()`, `turn-page()`, `line-sep()` |
| `\newpage` | `#pagebreak()`, anywhere |
| `\todo{}`, `\colored{}`, `\bigO{}`, `\vspc`, `\warning` | `todo[]`, `colored[]`, `big-o()`, `visible-space()`, `warning-sign()` |
| `\section{T}` (series) | `section[T]` |
| `\def\confidential{}` | `confidential: true` |
| tikz `[remember picture, overlay]` pictures | a top-level `place(bottom + right, dx: .., dy: .., image(..))` |
| `\faBug` and other Font Awesome glyphs | not bundled: `text(font: "FontAwesome", str.from-unicode(0xf188))` with the font on your `TYPST_FONT_PATHS`, or the `fontawesome` Universe package |

Known differences: the "Listing continues on next page…" notes of `mdframed` are not reproduced, and a LaTeX `\fill` sometimes printed only a few dotted lines where Typst fills the page.

## Checking against the LaTeX reference

```bash
tools/compare-exam.sh exam.typ reference.pdf reference-sol.pdf
```

renders the Typst document in both modes next to the LaTeX PDFs, one PNG per page (LaTeX left, Typst right), compares the page counts and the question structure of every page. See [`CONTRIBUTING.md`](https://github.com/ISC-HEI/isc-hei-exam/blob/main/CONTRIBUTING.md) for the development and release workflow.

## Dependencies

Only Typst is needed to write exams. The rest serves the development and the comparison tooling.

| Tool | Required for | Linux (Debian/Ubuntu) | macOS (Homebrew) |
| --- | --- | --- | --- |
| **typst** ≥ 0.14 | compiling | [GitHub release](https://github.com/typst/typst/releases) | `brew install typst` |
| **Source Sans 3** | the body font | `apt install fonts-adobe-sourcesans3` | [Google Fonts](https://fonts.google.com/specimen/Source+Sans+3) |
| **just** | the development recipes | `apt install just` | `brew install just` |
| **poppler-utils** | tests, `compare-exam.sh` | `apt install poppler-utils` | `brew install poppler` |
| **ImageMagick** | the comparison montages | `apt install imagemagick` | `brew install imagemagick` |
| **pngquant**, **zopfli** | the Universe thumbnail | `apt install pngquant zopfli` | `brew install pngquant zopfli` |

---

## License

Copyright © 2026 P.-A. Mudry / ISC — HES-SO Valais. Released under the [MIT License](https://github.com/ISC-HEI/isc-hei-exam/blob/main/LICENSE). The ISC and HES-SO logos shipped in `assets/` are the marks of their institutions and are not covered by that licence.

---

*Made with ♥ by mui, 2026*
