// The question tree: question(), part(), subpart() and their bonus variants.
//
// Like \question / \part / \subpart in exam.cls, these are FLAT sibling calls:
//
//   #question(title: [Loops])[intro]
//   #part(points: 4)[...]
//   #subpart[...]
//   #pagebreak()
//   #part(points: 2)[...]
//
// Typst forbids #pagebreak() inside containers, and a part is a container, so
// keeping the calls flat is what lets a plain #pagebreak() between two parts
// work. Nesting a #subpart inside a #part body is also accepted (the indent
// adapts); use new-page() instead of pagebreak() in that case.

#import "settings.typ": *
#import "state.typ": *
#import "points.typ": *

// One <isc-points> record. `number` is the visible question number.
#let points-record(kind, points, bonus, title: none, number: none) = context [
  #metadata((
    kind: kind,
    qid: qid-counter.get().first(),
    points: points,
    bonus: bonus,
    title: title,
    number: number,
  )) <isc-points>
]

// "[4 Pt]" / "[2 Bo]" in the left margin, aligned with the first line of the
// part. Emitted inside the label cell, hence body-relative: it follows the
// binding offset on odd/even pages exactly like \pointsinmargin does.
#let margin-points(points, bonus, depth: 0) = context {
  let unit = if bonus { emph(ui("bonus-abbrev")) } else { ui("points-abbrev") }
  let extra = if depth == 1 { part-label-width } else { 0mm }
  place(top + left, dx: -(margin-points-offset + extra),
    box(width: margin-points-width,
      align(left, text(size: size-normal)[\[#fmt-points(points) #unit\]])))
}

// Indented block for the body of a question / part / subpart. `target` is the
// absolute indent the body must have; the enclosing indent is subtracted.
#let indented(target, above: 0pt, below: 0pt, body) = context {
  let applied = indent-state.get()
  block(width: 100%, inset: (left: target - applied), above: above, below: below, {
    indent-state.update(target)
    body
    indent-state.update(applied)
  })
}

// \titledquestion{Title}[points] / \question[points]
// The heading is a real level-1 heading (PDF outline for free), built inside
// `context` so the bookmark carries the resolved "(X points)".
#let question(title: none, points: none, bonus: false, body) = {
  if not bonus { question-counter.step() }
  qid-counter.step()
  part-counter.update(0)
  subpart-counter.update(0)
  level-state.update("question")
  context {
    let n = question-counter.get().first()
    let qid = qid-counter.get().first()
    [#metadata((kind: "question", qid: qid, points: points, bonus: bonus, title: title, number: n)) <isc-points>]
    let label = if bonus { ui("question-bonus") } else { ui("question") + " " + str(n) }
    let head = strong(if title != none { [#label -- #title] } else { [#label] })
    let pts = if cfg("kind") == "exam" {
      let t = question-total(qid, bonus: bonus)
      if t > 0 { [ (#fmt-points(t) #ui(if bonus { "points-bonus" } else { "points" }))] } else { [] }
    } else { [] }
    heading(level: 1, numbering: none, outlined: false, bookmarked: true, head + pts)
  }
  if body != none and body != [] {
    indented(question-indent, above: question-below, below: par-spacing, body)
  }
}
#let bonus-question = question.with(bonus: true)

// \part[points] — label "(a)", points in the margin (exam) or inline (series).
#let part(points: none, bonus: false, body) = {
  part-counter.step()
  subpart-counter.update(0)
  level-state.update("part")
  points-record("part", points, bonus)
  context {
    let applied = indent-state.get()
    let kind = cfg("kind")
    if body == none or body == [] {
      // \part immediately followed by \subpart: LaTeX puts "(c)" and "1)" on the
      // same line. Emit a zero-height label so the next subpart shares the line.
      block(width: 100%, height: 0pt, inset: (left: question-indent - applied), above: part-above, below: part-above, {
        if points != none and kind == "exam" { margin-points(points, bonus, depth: 0) }
        place(top + left, dy: 0.65em, numbering(cfg("part-numbering", default: "(a)"), part-counter.get().first()))
      })
      return
    }
    block(width: 100%, inset: (left: question-indent - applied), above: part-above, below: part-below,
      grid(columns: (part-label-width, 1fr),
        {
          if points != none and kind == "exam" { margin-points(points, bonus, depth: 0) }
          numbering(cfg("part-numbering", default: "(a)"), part-counter.get().first())
        },
        {
          indent-state.update(question-indent + part-label-width)
          if points != none and kind != "exam" {
            [(#fmt-points(points) #ui(if bonus { "points-bonus" } else { "points" })) ]
          }
          body
          indent-state.update(applied)
        }))
  }
}
#let bonus-part = part.with(bonus: true)

// \subpart[points] — label "1)".
#let subpart(points: none, bonus: false, body) = {
  subpart-counter.step()
  level-state.update("subpart")
  points-record("subpart", points, bonus)
  context {
    let applied = indent-state.get()
    let kind = cfg("kind")
    let target = question-indent + part-label-width
    block(width: 100%, inset: (left: target - applied), above: part-below, below: part-below,
      grid(columns: (subpart-label-width, 1fr),
        {
          if points != none and kind == "exam" { margin-points(points, bonus, depth: 1) }
          numbering(cfg("subpart-numbering", default: "1)"), subpart-counter.get().first())
        },
        {
          indent-state.update(target + subpart-label-width)
          if points != none and kind != "exam" {
            [(#fmt-points(points) #ui(if bonus { "points-bonus" } else { "points" })) ]
          }
          body
          indent-state.update(applied)
        }))
  }
}
#let bonus-subpart = subpart.with(bonus: true)

// \section{Title} of the series template: "Part N - Title", full width.
#let section(title) = {
  section-counter.step()
  context {
    block(width: 100%, above: 1.2em, below: 0.6em,
      text(size: size-Large, weight: "bold", style: "italic")[#ui("part") #section-counter.get().first() - #title])
  }
}

// Indent stray top-level content to the question body level ("Votre solution :").
#let indent(body) = indented(question-indent, body)
