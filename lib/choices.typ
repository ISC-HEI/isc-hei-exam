// Multiple-choice and true/false.
//
//   #choices([Affiche `0`], correct[Affiche `5`], [Une exception])   stacked, square boxes
//   #choices(inline: true, [`true`], correct[`false`])                in the running text, round
//
//   #true-false(
//     is-true[`val b: Double = 4`],
//     is-false[`val a: Int = 3.2`],
//   )
//
// In the solutions the correct choice is filled (square) or marked √ (round), and
// the true/false answer shows ⊗. The exam.cls names (checkboxes, inline-checkboxes,
// correct-choice, begin-true-false) remain available.

#import "settings.typ": *
#import "state.typ": *

// A drawn checkbox (font independent). `shape: "square"` is \checkboxchar{$\Box$}
// (stacked choices), `shape: "circle"` is the $\bigcirc$ of oneparcheckboxes;
// a checked box is filled (\checkedchar{$\blacksquare$}). Sizes measured on the
// LaTeX references.
#let checkbox(checked: false, shape: "square", size: auto) = {
  let s = if size != auto { size } else if shape == "circle" { 0.95em } else { 0.68em }
  let fill = if checked { black } else { none }
  if shape == "circle" and checked {
    // exam.cls \CorrectChoice in oneparcheckboxes: the $\surd$ mark replaces the circle
    box(width: s, align(center, text(size: 1.2em)[√]))
  } else if shape == "circle" {
    box(baseline: 0.15em, circle(radius: s / 2, stroke: 0.5pt + black, fill: none))
  } else {
    box(width: s, height: s, stroke: 0.5pt + black, baseline: 0.03em, fill: fill)
  }
}

// ── Choices ───────────────────────────────────────────────────────────────────
// Items: plain content is a wrong choice, correct[...] a right one.
#let correct(body) = (correct: true, body: body)
#let choice(body) = (correct: false, body: body)
#let correct-choice = correct
#let as-item(c) = if type(c) == dictionary { c } else { (correct: false, body: c) }

// choices(inline: false, shape: auto, ..items)
#let choices(inline: false, shape: auto, ..items) = {
  let shape = if shape != auto { shape } else if inline { "circle" } else { "square" }
  let its = items.pos().map(as-item)
  if inline {
    // oneparcheckboxes: \hspace before the first choice, \quad-ish between choices.
    context {
      let sol = solutions-state.get()
      h(1em)
      its.map(c =>
        box[#checkbox(checked: sol and c.correct, shape: shape)#h(0.55em)#if sol and c.correct { strong(c.body) } else { c.body }]
      ).join(h(2em))
    }
  } else {
    at-level(context {
      let sol = solutions-state.get()
      block(width: 100%, above: 0.5em, below: 0.5em, inset: (left: 2em),
        stack(spacing: 0.7em, ..its.map(c =>
          grid(columns: (1.4em, 1fr), align: horizon,
            checkbox(checked: sol and c.correct, shape: shape),
            if sol and c.correct { strong(c.body) } else { c.body }))))
    })
  }
}
#let checkboxes(shape: "square", ..items) = choices(shape: shape, ..items)
#let inline-checkboxes(shape: "circle", ..items) = choices(inline: true, shape: shape, ..items)

// ── True / false ──────────────────────────────────────────────────────────────
#let is-true(body) = (answer: true, body: body)
#let is-false(body) = (answer: false, body: body)

#let as-bool(v) = if type(v) == bool { v }
  else if type(v) == str { lower(v) == "true" }
  else { lower(repr(v).replace("[", "").replace("]", "")) == "true" }

// \dash: the hairline dashed rule between rows (\hdashrule 0.25pt). Not indented
// by itself: the block around it is.
#let dash-rule-raw() = block(width: 100%, above: 0pt, below: 0pt,
  line(length: 100%, stroke: (thickness: 0.25pt, dash: "densely-dashed", paint: black)))
#let dash-rule() = at-level(dash-rule-raw())

// One row: statement on the left, "True | False" with two boxes on the right,
// the dashed rule under it.
#let tf-row(statement, ans, sol) = {
  let mark(v) = if sol and ans == v { text(size: 1.15em)[$times.o$] } else { checkbox() }
  // options.tex adds \vspace{0.9mm} per row in the student version only.
  let sp = if sol { 0.52em } else { 0.65em }
  block(width: 100%, above: sp, below: sp,
    grid(columns: (1fr, 2.5cm), column-gutter: 1em, align: (left + horizon, right + bottom),
      statement,
      table(columns: 2, align: center, inset: (x: 5pt, y: 2.5pt),
        stroke: (x, y) => if x == 0 { (right: 0.4pt + black) } else { none },
        emph(ui("true")), emph(ui("false")), mark(true), mark(false))))
  dash-rule-raw()
}

// true-false(..items, rule: true): items are is-true[...] / is-false[...], or
// (statement, bool) pairs. `rule: false` drops the leading dashed rule.
// Legacy form, one row without the leading rule: true-false[statement][true].
#let true-false(..items, rule: true) = {
  let pos = items.pos()
  let legacy = pos.len() == 2 and type(pos.at(0)) == content and (
    type(pos.at(1)) in (bool, str) or (type(pos.at(1)) == content and lower(repr(pos.at(1))) in ("[true]", "[false]")))
  let rows = if legacy { ((body: pos.at(0), answer: as-bool(pos.at(1))),) }
    else { pos.map(it => if type(it) == array { (body: it.at(0), answer: as-bool(it.at(1))) } else { it }) }
  at-level(context {
    let sol = solutions-state.get()
    if rule and not legacy { dash-rule-raw(); v(-1mm) }
    for r in rows { tf-row(r.body, r.answer, sol) }
  })
}

// \begintruefalse — the leading rule, for the legacy one-row-per-call form.
#let begin-true-false() = { dash-rule(); v(-1mm) }
