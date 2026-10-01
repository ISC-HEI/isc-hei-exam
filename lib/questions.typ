// The question tree: question(), part(), subpart() and their bonus variants.
//
//   #question[Short questions]                     title only
//   #question[Loops][Que vont afficher…]           title and intro
//   #question(points: 3)[Debugging]                points on the question itself
//   #part(3)[…]  #bonus-part(2)[…]  #subpart(1)[…]  points positional (points: 3 works too)
//
// Like \question / \part / \subpart in exam.cls, these are FLAT sibling calls:
//
//   #question[Loops]
//   #part(4)[...]
//   #subpart[...]
//   #pagebreak()
//   #part(2)[...]
//
// Typst forbids #pagebreak() inside containers, and a part is a container, so
// keeping the calls flat is what lets a plain #pagebreak() between two parts
// work. Nesting a #subpart inside a #part body is also accepted (the indent
// adapts); use new-page() instead of pagebreak() in that case.
//
// A trailing answer(1fr) in a part body is hoisted out of the part so that it
// behaves like LaTeX's \fill (see answers.typ).

#import "settings.typ": *
#import "state.typ": *
#import "points.typ": *
#import "answers.typ": split-trailing-fill, answer-line

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

// Indented block for the body of a question. `target` is the absolute indent
// the body must have; the enclosing indent is subtracted.
#let indented(target, above: 0pt, below: 0pt, body) = context {
  let applied = indent-state.get()
  block(width: 100%, inset: (left: target - applied), above: above, below: below, {
    indent-state.update(target)
    body
    indent-state.update(applied)
  })
}

// Positional arguments of part()/subpart(): a number is the points, content the body.
#let split-part-args(pos, points) = {
  let pts = points
  let body = none
  for a in pos {
    if type(a) in (int, float) { pts = a } else { body = a }
  }
  (pts, body)
}

#let is-empty(body) = body == none or body == []

// \titledquestion{Title}[points] / \question[points]
// Positional: question[Title], question[Title][intro]; or title: with the intro as body.
// The heading is a real level-1 heading (PDF outline for free), built inside
// `context` so the bookmark carries the resolved "(X points)".
#let question(..args, title: none, intro: none, points: none, bonus: false) = {
  let pos = args.pos()
  let (title, body) = if intro != none { (if title != none { title } else { pos.at(0, default: none) }, intro) }
    else if title != none { (title, pos.at(0, default: none)) }
    else if pos.len() >= 2 { (pos.at(0), pos.at(1)) }
    else if pos.len() == 1 { (pos.at(0), none) }
    else { (none, none) }
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
  if not is-empty(body) {
    indented(question-indent, above: question-below, below: par-spacing, body)
  }
}
#let bonus-question = question.with(bonus: true)

// Shared rendering of a part / subpart row. `inner` is the body without its
// trailing fill (see split-trailing-fill).
#let labelled-row(target, label-width, label, inner, above: part-above, below: part-below, margin: none, inline-points: none) = context {
  let applied = indent-state.get()
  if is-empty(inner) {
    // \part immediately followed by \subpart: LaTeX puts "(c)" and "1)" on the
    // same line. Emit a zero-height label so the next subpart shares the line.
    block(width: 100%, height: 0pt, inset: (left: target - applied), above: above, below: above, {
      if margin != none { margin }
      place(top + left, dy: 0.65em, label)
    })
    return
  }
  block(width: 100%, inset: (left: target - applied), above: above, below: below,
    grid(columns: (label-width, 1fr),
      { if margin != none { margin }; label },
      {
        indent-state.update(target + label-width)
        if inline-points != none { inline-points }
        inner
        indent-state.update(applied)
      }))
}

// A part/subpart title (\part[3] \subsection*{T} in the LaTeX exams): a level-2
// heading as the first line of the body.
#let with-title(title, body) = if title == none { body } else { [== #title] + (if body == none { [] } else { body }) }

#let inline-points(points, bonus) = if points == none { none } else {
  context [(#fmt-points(points) #ui(if bonus { "points-bonus" } else { "points" })) ]
}

// \part[points] — label "(a)", points in the margin (exam) or inline (series).
// `title:` puts a bold title on the first line (\subsection* inside the part).
#let part(..args, points: none, bonus: false, title: none) = {
  let (points, body) = split-part-args(args.pos(), points)
  let (inner, trailing) = split-trailing-fill(with-title(title, body))
  part-counter.step()
  subpart-counter.update(0)
  level-state.update("part")
  points-record("part", points, bonus)
  context {
    let exam = cfg("kind") == "exam"
    labelled-row(question-indent, part-label-width,
      numbering(cfg("part-numbering", default: "(a)"), part-counter.get().first()), inner,
      margin: if points != none and exam { margin-points(points, bonus, depth: 0) },
      inline-points: if not exam { inline-points(points, bonus) })
  }
  // A trailing 1fr answer space, hoisted after the container: LaTeX glue semantics.
  // Emitted outside the context block so that an enclosing part can hoist it again.
  trailing
}
#let bonus-part = part.with(bonus: true)

// \subpart[points] — label "1)".
#let subpart(..args, points: none, bonus: false, title: none) = {
  let (points, body) = split-part-args(args.pos(), points)
  let (inner, trailing) = split-trailing-fill(with-title(title, body))
  subpart-counter.step()
  level-state.update("subpart")
  points-record("subpart", points, bonus)
  context {
    let exam = cfg("kind") == "exam"
    let in-part = part-counter.get().first() > 0
    labelled-row(subpart-base(), subpart-label-width,
      numbering(cfg("subpart-numbering", default: "1)"), subpart-counter.get().first()), inner,
      above: subpart-gap, below: subpart-gap,
      margin: if points != none and exam { margin-points(points, bonus, depth: if in-part { 1 } else { 0 }) },
      inline-points: if not exam { inline-points(points, bonus) })
  }
  trailing
}
#let bonus-subpart = subpart.with(bonus: true)

// The "give the type and value of each expression" block: one subpart with an
// answer line per (expression, answer) pair.
//
//   #short-answers(
//     (`a + b`, [Int]),
//     (`(d + b).toShort`, [Short]),
//   )
#let short-answers(..pairs, level: "subpart", length: auto, points: none) = {
  let item = if level == "part" { part } else { subpart }
  for p in pairs.pos() {
    let (expr, ans) = if type(p) == array { (p.at(0), p.at(1, default: none)) } else { (p, none) }
    item(points: points)[#expr #answer-line(ans, length: length)]
  }
}

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
