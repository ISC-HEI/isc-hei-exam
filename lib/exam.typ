// isc-exam(): the show rule. `series` is the same with kind: "series".
//
//   #show: isc-exam.with(title: [Test semestriel], course: [101.1 -- Programmation impérative], ...)
//
// Student version:  typst compile exam.typ
// Solutions:        typst compile --input solutions=true exam.typ exam-sol.pdf
// (or pass `solutions: true`; the parameter wins over the input.)

#import "settings.typ": *
#import "fonts.typ": *
#import "state.typ": *
#import "points.typ" as points
#import "code.typ": listing-rules
#import "headers.typ": *
#import "cover.typ": exam-cover
#import "questions.typ": structure

#let isc-exam(
  kind: "exam",                 // "exam" | "series"
  solutions: auto,              // auto → --input solutions=true; a bool wins
  title: [Titre],               // exam: cover title (small caps); series: short title ("Série 2")
  subtitle: none,               // series only: "Série 2 -- Expressions"
  course: none,                 // "101.1 -- Programmation impérative"
  date: none,                   // exam: even-page running header
  month: none,                  // exam: first-page footer centre
  teachers: none,               // exam: first-page footer left; series: footer left
  revision: none,               // exam: tiny line under the title box; series: header right
  lang: "fr",
  region: "CH",
  ui-lang: auto,                // language of the UI strings; auto = lang
  extra-i18n: none,             // (fr: (key: "value")) overrides
  logo: auto,                   // cover logo: auto = the ISC inline logo, none, or content
  logo-width: 7.5cm,
  logo-pos: (x: 1.4cm, y: 9mm), // from the top-right page corner
  footer-logo: auto,            // running-footer logo: auto = HES-SO Valais/Wallis, none, or content
  font: none,                   // body font override
  check-fonts: true,            // false: render even when the body font is missing
  confidential: false,          // true or a string: diagonal watermark
  instructions: none,           // content of the cover title box ("Consigne")
  grade-table: auto,            // auto | "simple" | "combined" | none
  expected-total: none,         // the announced total; a red note appears on the cover if the points differ
  cover-top-space: 3cm,         // \vspace*{...} before the title rules (1.5cm in the sample exam)
  name-fields: (:),             // see cover.typ name-fields-default
  answer-line-length: auto,     // 3cm (exam) / 5.5cm (series)
  page-margin: (:),             // overrides merged into the default margins, e.g. (bottom: 22mm)
  part-numbering: "(a)",
  subpart-numbering: "1)",
  body,
) = {
  assert(kind in ("exam", "series"), message: "isc-hei-exam: kind must be \"exam\" or \"series\"")
  // Marker-style questions / parts / subparts: cut the document into items.
  let body = structure(body)
  let is-exam = kind == "exam"
  let sol = resolve-solutions(solutions)
  let ui-lang = if ui-lang == auto { lang } else { ui-lang }
  let fnt = if font == none { body-font } else { font }
  let logo = if logo == auto { image("../assets/isc_logo.svg") } else { logo }
  let footer-logo = if footer-logo == auto { image("../assets/hesso_valais.svg") } else { footer-logo }
  let all = if answer-line-length == auto {
    if is-exam { answer-line-length-exam }
    else if sol { answer-line-length-series-sol } else { answer-line-length-series }
  } else { answer-line-length }

  // ── Document, text, paragraphs ────────────────────────────────────────────
  set document(title: title, author: if teachers != none and type(teachers) == str { teachers } else { () })
  set text(font: fnt, size: size-normal, lang: lang, region: region, number-type: "lining")
  set par(justify: true, leading: body-leading, spacing: par-spacing)
  // LaTeX never turns straight quotes into guillemets; neither do we.
  set smartquote(enabled: false)
  // babel-french itemize marker is an en dash; \itemsep + \parsep ≈ 8pt.
  set list(marker: if lang == "fr" { [–] } else { [•] }, indent: 0em, body-indent: 1.1em, spacing: 0.8em)
  set enum(indent: 0em, body-indent: 0.8em, spacing: 0.8em)
  show list: set block(above: 0.9em, below: 0.9em)   // \topsep
  show enum: set block(above: 0.9em, below: 0.9em)
  show link: set text(fill: url-color)
  set heading(numbering: none, outlined: false)

  // ── Page ──────────────────────────────────────────────────────────────────
  let watermark = if confidential == false { none } else {
    align(center + horizon, rotate(-45deg,
      text(size: 64pt, weight: "bold", fill: watermark-color, if confidential == true { "CONFIDENTIAL" } else { confidential })))
  }
  set page(
    paper: "a4",
    margin: (if is-exam { exam-margin } else { series-margin }) + page-margin,
    binding: left,
    header: if is-exam { exam-header } else { series-header },
    footer: if is-exam { exam-footer } else { series-footer },
    header-ascent: if is-exam { exam-header-ascent } else { series-header-ascent },
    footer-descent: if is-exam { exam-footer-descent } else { series-footer-descent },
    background: watermark,
  )

  // ── Headings: level 1 = question (built by question()), level 2 = \subsection*
  show heading.where(level: 1): it => block(width: 100%, above: question-above, below: question-below,
    text(size: if is-exam { size-Large } else { size-large }, weight: "regular", it.body))
  show heading.where(level: 2): it => block(width: 100%, above: 1.5em, below: 0.6em,
    text(size: size-large, weight: "bold", it.body))
  show heading.where(level: 3): it => block(width: 100%, above: 0.8em, below: 0.4em,
    text(size: size-normal, weight: "bold", it.body))

  // ── Listings ──────────────────────────────────────────────────────────────
  show: listing-rules

  // ── Figures: babel-french caption "Figure 1 – ..." with a small-caps label ─
  set figure(gap: 1em)
  show figure.caption: it => context {
    set text(size: size-small)
    smallcaps[#it.supplement #it.counter.display(it.numbering)]
    [ -- ]
    it.body
  }

  // ── State ─────────────────────────────────────────────────────────────────
  solutions-state.update(sol)
  cfg-state.update((
    kind: kind, lang: lang, ui-lang: ui-lang, extra-i18n: extra-i18n,
    title: title, subtitle: subtitle, course: course, date: date, month: month,
    teachers: teachers, revision: revision, footer-logo: footer-logo, expected-total: expected-total,
    answer-line-length: all, part-numbering: part-numbering, subpart-numbering: subpart-numbering,
  ))

  // ── Fonts guard, then the document ────────────────────────────────────────
  context {
    if check-fonts and not isc-fonts-available() {
      missing-fonts-page()
    } else if is-exam {
      exam-cover(instructions: instructions, grade-mode: grade-table, top-space: cover-top-space,
        logo: logo, logo-width: logo-width, logo-pos: logo-pos, name-fields: name-fields)
      pagebreak()
      body
    } else {
      // Series: centred title block, then the questions on the same page.
      align(center, {
        let t = if sol { [#title -- #ui("solution-suffix")] }
          else if subtitle != none { [#title -- #subtitle] } else { title }
        text(size: size-huge, weight: "bold", t)
        linebreak()
        text(size: size-large, style: "italic", course)
      })
      body
    }
  }
}

#let series = isc-exam.with(kind: "series")
