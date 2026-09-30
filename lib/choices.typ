// Multiple-choice checkboxes and true/false rows.

#import "settings.typ": *
#import "state.typ": *

// A drawn checkbox (font independent). `shape: "square"` is \checkboxchar{$\Box$}
// (stacked `checkboxes`), `shape: "circle"` is the $\bigcirc$ of `oneparcheckboxes`;
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

// Items of checkboxes(): plain content is a wrong choice; correct-choice[...]
// marks the right one(s). choice[...] is optional sugar.
#let choice(body) = (correct: false, body: body)
#let correct-choice(body) = (correct: true, body: body)
#let as-item(c) = if type(c) == dictionary { c } else { (correct: false, body: c) }

// \begin{checkboxes} — one choice per line, square boxes.
#let checkboxes(shape: "square", ..items) = at-level(context {
  let sol = solutions-state.get()
  block(width: 100%, above: 0.5em, below: 0.5em, inset: (left: 2em),
    stack(spacing: 0.7em, ..items.pos().map(as-item).map(c =>
      grid(columns: (1.4em, 1fr), align: horizon,
        checkbox(checked: sol and c.correct, shape: shape),
        if sol and c.correct { strong(c.body) } else { c.body }))))
})

// \begin{oneparcheckboxes} — choices inline, in the running paragraph, round boxes.
#let inline-checkboxes(shape: "circle", ..items) = context {
  let sol = solutions-state.get()
  // oneparcheckboxes: \hspace before the first choice, \quad-ish between choices.
  h(1em)
  items.pos().map(as-item).map(c =>
    box[#checkbox(checked: sol and c.correct, shape: shape)#h(0.55em)#if sol and c.correct { strong(c.body) } else { c.body }]
  ).join(h(2em))
}

// \dash: the hairline dashed rule between true/false rows (\hdashrule 0.25pt).
#let dash-rule() = at-level(block(width: 100%, above: 0pt, below: 0pt,
  line(length: 100%, stroke: (thickness: 0.25pt, dash: "densely-dashed", paint: black))))

// \begintruefalse — the leading rule.
#let begin-true-false() = { dash-rule(); v(-1mm) }

// \truefalse{statement}{true|false}: statement on the left, a small
// "True | False" table with two boxes on the right; the solution marks the
// answer with ⊗. `answer` may be a bool, "true"/"false" or [true]/[false].
#let true-false(statement, answer) = at-level(context {
  let ans = if type(answer) == bool { answer }
    else if type(answer) == str { lower(answer) == "true" }
    else { lower(repr(answer).replace("[", "").replace("]", "")) == "true" }
  let sol = solutions-state.get()
  let mark(v) = if sol and ans == v { text(size: 1.15em)[$times.o$] } else { checkbox() }
  // options.tex adds \vspace{0.9mm} per row in the student version only.
  let sp = if sol { 0.52em } else { 0.65em }
  block(width: 100%, above: sp, below: sp,
    grid(columns: (1fr, 2.5cm), column-gutter: 1em, align: (left + horizon, right + bottom),
      statement,
      table(columns: 2, align: center, inset: (x: 5pt, y: 2.5pt),
        stroke: (x, y) => if x == 0 { (right: 0.4pt + black) } else { none },
        emph(ui("true")), emph(ui("false")), mark(true), mark(false))))
  dash-rule()
})
