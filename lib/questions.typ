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

// ── Markers ───────────────────────────────────────────────────────────────────
// Called WITHOUT a body, question / part / subpart return a marker; the text that
// follows, up to the next marker, is their body. isc-exam() does the cutting
// (see structure() below). Exactly the exam.cls way of writing:
//
//   #question[Short questions]
//   Cette question est séparée en plusieurs exercices.
//   #part(3)
//   Qu'affiche le code suivant ?
//   #answer(2cm)[…]
//   #pagebreak()
//   #part(4)
//   …
//   #end-parts()        ← back to the question level (\end{parts}), rarely needed
//
#let marker(kind, ..fields) = [#metadata((isc-marker: kind, ..fields.named()))<isc-marker>]

// The marker dictionary of a child, or none. The markup label leaves the metadata
// inside a small sequence (possibly with a space), hence the descent.
#let marker-of(c) = {
  if type(c) != content { return none }
  if c.func() == metadata and type(c.value) == dictionary and "isc-marker" in c.value { return c.value }
  if c.has("children") {
    let real = c.children.filter(x => repr(x.func()) != "space")
    if real.len() == 1 { return marker-of(real.first()) }
  }
  none
}

// \titledquestion{Title}[points] / \question[points]
// Positional: question[Title], question[Title][intro]; or title: with the intro as body.
// The heading is a real level-1 heading (PDF outline for free), built inside
// `context` so the bookmark carries the resolved "(X points)".
#let item-tag(kind) = metadata((isc-item: kind))
#let item-of(c) = if type(c) == content and c.has("children") and c.children.len() > 0 {
  let f = c.children.first()
  if f.func() == metadata and type(f.value) == dictionary and "isc-item" in f.value { f.value.isc-item } else { none }
} else { none }

#let question-impl(title, points, bonus, body) = {
  item-tag("question")
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

#let question(..args, title: none, intro: none, points: none, bonus: false) = {
  let pos = args.pos()
  let (title, body) = if intro != none { (if title != none { title } else { pos.at(0, default: none) }, intro) }
    else if title != none { (title, pos.at(0, default: none)) }
    else if pos.len() >= 2 { (pos.at(0), pos.at(1)) }
    else if pos.len() == 1 { (pos.at(0), none) }
    else { (none, none) }
  if body == none { marker("question", title: title, points: points, bonus: bonus) }
  else { question-impl(title, points, bonus, body) }
}
#let bonus-question = question.with(bonus: true)

// Shared rendering of a part / subpart row. `inner` is the body without its
// trailing fill (see split-trailing-fill). `label: none` renders the continuation
// of an item after a page break (no label, no points).
#let labelled-row(target, label-width, label, inner, above: part-above, below: part-below, margin: none, inline-points: none) = context {
  let applied = indent-state.get()
  if is-empty(inner) and label != none {
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

// The part / subpart label is a real heading (level 2 / 3). Headings are what
// Tinymist's preview outline in VS Code and the PDF bookmarks are built from,
// so the exam structure shows up there under each question, down to
// `outline-depth` (isc-exam parameter, default 3; 1 keeps questions only).
// isc-exam() renders headings carrying these supplements as the bare label.
#let outline-label(level, kind, label, title) = heading(level: level, numbering: none, outlined: false,
  bookmarked: level <= cfg("outline-depth", default: 3), supplement: [#kind],
  if title == none { label } else { [#label #title] })

#let inline-points(points, bonus) = if points == none { none } else {
  context [(#fmt-points(points) #ui(if bonus { "points-bonus" } else { "points" })) ]
}

// \part[points] — label "(a)", points in the margin (exam) or inline (series).
#let part-impl(points, bonus, title, body, continuation: false) = {
  let (inner, trailing) = split-trailing-fill(with-title(title, body))
  item-tag("part")
  if not continuation {
    part-counter.step()
    subpart-counter.update(0)
    level-state.update("part")
    points-record("part", points, bonus)
  }
  context {
    let exam = cfg("kind") == "exam"
    labelled-row(question-indent, part-label-width,
      if continuation { none } else { outline-label(2, "isc-part", numbering(cfg("part-numbering", default: "(a)"), part-counter.get().first()), title) }, inner,
      margin: if points != none and exam and not continuation { margin-points(points, bonus, depth: 0) },
      inline-points: if not exam and not continuation { inline-points(points, bonus) })
  }
  // A trailing 1fr answer space, hoisted after the container: LaTeX glue semantics.
  // Emitted outside the context block so that an enclosing part can hoist it again.
  trailing
}

// `title:` puts a bold title on the first line (\subsection* inside the part).
// Without a body: a marker (see above).
#let part(..args, points: none, bonus: false, title: none) = {
  let (points, body) = split-part-args(args.pos(), points)
  if is-empty(body) { marker("part", points: points, bonus: bonus, title: title) }
  else { part-impl(points, bonus, title, body) }
}
#let bonus-part = part.with(bonus: true)

// \subpart[points] — label "1)".
#let subpart-impl(points, bonus, title, body, continuation: false) = {
  let (inner, trailing) = split-trailing-fill(with-title(title, body))
  item-tag("subpart")
  if not continuation {
    subpart-counter.step()
    level-state.update("subpart")
    points-record("subpart", points, bonus)
  }
  context {
    let exam = cfg("kind") == "exam"
    let in-part = part-counter.get().first() > 0
    labelled-row(subpart-base(), subpart-label-width,
      if continuation { none } else { outline-label(3, "isc-subpart", numbering(cfg("subpart-numbering", default: "1)"), subpart-counter.get().first()), title) }, inner,
      above: subpart-gap, below: subpart-gap,
      margin: if points != none and exam and not continuation { margin-points(points, bonus, depth: if in-part { 1 } else { 0 }) },
      inline-points: if not exam and not continuation { inline-points(points, bonus) })
  }
  trailing
}

#let subpart(..args, points: none, bonus: false, title: none) = {
  let (points, body) = split-part-args(args.pos(), points)
  if is-empty(body) { marker("subpart", points: points, bonus: bonus, title: title) }
  else { subpart-impl(points, bonus, title, body) }
}
#let bonus-subpart = subpart.with(bonus: true)

// \end{parts}: what follows belongs to the question again (unindented top level).
#let end-parts() = marker("end")

// ── Structure pass (called by isc-exam on the whole document) ─────────────────
// Walks the top-level children; a marker opens an item that collects the children
// up to the next marker. A #pagebreak() inside an item closes it, is emitted at the
// top level, and the item continues unlabelled on the next page.
#let is-blank(children) = children.all(c => c.func() == parbreak or repr(c.func()) == "space")

#let render-item(m, buf, continuation: false) = {
  let body = if is-blank(buf) { none } else { buf.join() }
  // Nothing left of the item after a page break: render nothing (no empty row).
  if continuation and body == none { return none }
  let k = m.isc-marker
  if k == "question" {
    if continuation { if body != none { indented(question-indent, body) } }
    else { question-impl(m.title, m.points, m.bonus, body) }
  } else if k == "part" { part-impl(m.points, m.bonus, m.title, body, continuation: continuation) }
  else if k == "subpart" { subpart-impl(m.points, m.bonus, m.title, body, continuation: continuation) }
}

#let structure(body) = {
  let ch = if body == none { () } else if body.has("children") { body.children } else { (body,) }
  let out = ()
  let open = none        // (marker, continuation)
  let buf = ()
  let flush(open, buf, continuation) = if open != none { render-item(open, buf, continuation: continuation) } else { buf.join() }
  let cont = false
  for c in ch {
    let m = marker-of(c)
    if m != none {
      out.push(flush(open, buf, cont)); buf = (); cont = false
      open = if m.isc-marker == "end" { none } else { m }
    } else if item-of(c) != none {
      // a question / part / subpart written with brackets closes the open marker
      out.push(flush(open, buf, cont)); buf = (); cont = false
      open = none
      out.push(c)
    } else if open != none and c.func() == pagebreak {
      out.push(flush(open, buf, cont)); buf = ()
      out.push(c)
      cont = true
    } else {
      buf.push(c)
    }
  }
  out.push(flush(open, buf, cont))
  out.join()
}

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
