// Answer spaces: dotted lines, empty boxes, framed solutions, answer lines.
//
//   #answer(3cm)[solution]                 students: 3cm of dotted lines;  solutions: framed box
//   #answer(2cm, style: "lines")[…]        students: ruled lines
//   #answer(1fr, style: "box")[…]          students: an empty framed box filling the page
//   #answer(blank: 3cm)[…]                 students: 3cm of nothing
//   #solution[…]                           students: nothing at all;        solutions: framed box
//
// `1fr` is LaTeX's \fill. Typst resolves a fractional height against the enclosing
// container, so a 1fr space INSIDE a part would swallow the rest of the page and push
// what follows to the next page. part() and subpart() therefore hoist a trailing
// `answer(1fr)` out of their body, after the container, where it behaves like glue:
// what follows on the same page still fits. Writing the space after the part call
// yourself has the same effect.
//
// The exam.cls names (solution-or-dotted-lines, solution-or-box, …) remain available.

#import "settings.typ": *
#import "state.typ": *
#import "code.typ": verbatim

#let dotted-leader = box(width: 100%, repeat([.], gap: 0.3em))
#let solid-leader = line(length: 100%, stroke: 0.4pt + black)

// ── The page-fill marker (read by part() / subpart() to hoist the space) ───────
#let fill-marker = metadata("isc-fill")
#let with-fill-marker(height, body) = {
  if type(height) == fraction { fill-marker }
  body
}
#let is-fill-space(c) = c.has("children") and c.children.any(x => x.func() == metadata and x.value == "isc-fill")

// Split `body` into (everything before, trailing fill space or none). Looks
// through the last child too, so a fill hoisted out of a nested subpart (the
// last child of the part body is then the subpart's output) cascades upwards.
#let split-trailing-fill(body) = {
  if body == none or not body.has("children") { return (body, none) }
  let ch = body.children
  let i = ch.len() - 1
  while i >= 0 and (ch.at(i).func() == parbreak or repr(ch.at(i).func()) == "space") { i -= 1 }
  if i < 0 { return (body, none) }
  let last = ch.at(i)
  if is-fill-space(last) { return (ch.slice(0, i).join(), last) }
  if last.has("children") {
    let (inner, trailing) = split-trailing-fill(last)
    if trailing != none { return ((ch.slice(0, i) + (inner,)).join(), trailing) }
  }
  (body, none)
}

// A block of `height` filled with `leader` every \linefillheight (0.25in).
#let fill-with(height, leader) = with-fill-marker(height, context {
  let ind = top-level-indent()
  align(right, block(width: 100% - ind, height: height, breakable: false, above: 0.6em, below: 0.6em,
    layout(size => {
      let n = calc.max(1, calc.floor(size.height / line-fill-height))
      for i in range(n) {
        place(top + left, dy: (i + 1) * line-fill-height - 0.4em, leader)
      }
    })))
})

// \fillwithdottedlines{h} / \fillwithlines{h}
#let fill-with-dotted-lines(height) = fill-with(height, dotted-leader)
#let fill-with-lines(height) = fill-with(height, solid-leader)

// exam.cls TheSolution: framed, "Solution:" in bold, then the answer.
#let solution-box(body, min-height: none) = context {
  let ind = top-level-indent()
  let extra = if min-height == none { (:) } else { (height: min-height) }
  // align(right) positions the box; align(left) keeps its content left-aligned.
  align(right, block(width: 100% - ind, stroke: solution-stroke + black, inset: (x: 7pt, y: 8pt), breakable: true,
    above: 0.6em, below: 0.6em, ..extra,
    align(left)[#strong(ui("solution"))#h(0.5em)#body]))
}

// \begin{solution}[h]
#let solution(height: none, body) = with-fill-marker(height, context {
  if solutions-state.get() { solution-box(body) }
  else if height != none { v(height) }
})

// \begin{solutionordottedlines}[h]
#let solution-or-dotted-lines(height, body) = with-fill-marker(height, context {
  if solutions-state.get() { solution-box(body) } else { fill-with(height, dotted-leader) }
})

// \begin{solutionorlines}[h]
#let solution-or-lines(height, body) = with-fill-marker(height, context {
  if solutions-state.get() { solution-box(body) } else { fill-with(height, solid-leader) }
})

// \begin{solutionorbox}[h]
#let solution-or-box(height, body) = with-fill-marker(height, context {
  if solutions-state.get() { solution-box(body) }
  else {
    let ind = top-level-indent()
    align(right, block(width: 100% - ind, height: height, stroke: solution-stroke + black, breakable: false, above: 0.6em, below: 0.6em))
  }
})

// The one answer space. `answer(h)[sol]`, `answer(h, style: "lines" | "box")[sol]`,
// `answer(blank: h)[sol]`. `h` is a length or 1fr.
#let answer(..args, style: "dotted", blank: none) = {
  let pos = args.pos()
  assert(pos.len() >= 1, message: "answer: the solution body is missing")
  let body = pos.last()
  let height = if pos.len() >= 2 { pos.first() } else { none }
  if blank != none { solution(height: blank, body) }
  else {
    assert(height != none, message: "answer: give a height, e.g. answer(3cm)[…] or answer(1fr)[…], or blank: h")
    if style == "dotted" { solution-or-dotted-lines(height, body) }
    else if style == "lines" { solution-or-lines(height, body) }
    else if style == "box" { solution-or-box(height, body) }
    else { panic("answer: style must be \"dotted\", \"lines\" or \"box\"") }
  }
}

// \answerline[answer] — right-aligned rule of \answerlinelength, preceded by
// the current part / subpart label; the answer sits on the rule in the
// solutions. Accepts the answer positionally or as `answer:`.
#let answer-line(..args, length: auto) = context {
  let answer = args.pos().at(0, default: args.named().at("answer", default: none))
  let w = if length == auto { cfg("answer-line-length", default: answer-line-length-exam) } else { length }
  let lvl = level-state.get()
  let label = if lvl == "part" { numbering(cfg("part-numbering", default: "(a)"), part-counter.get().first()) }
    else if lvl == "subpart" { numbering(cfg("subpart-numbering", default: "1)"), subpart-counter.get().first()) }
    else { none }
  let ans = if solutions-state.get() and answer != none { strong(answer) } else { none }
  // exam.cls sets the answer in \hbox to \answerlinelength{\hfil #1\hss}: centred on the
  // rule, and when it is wider than the rule it starts at the rule and overflows to
  // the right on ONE line — never wrapped.
  let ans = if ans == none { none } else {
    let aw = measure(ans).width          // natural single-line width
    let one-line = box(width: aw, ans)   // a box sized to it cannot wrap
    if aw > w { align(left, one-line) } else { align(center, one-line) }
  }
  // exam.cls: \par \nobreak \vskip \answerskip (2ex) then the label and the rule.
  // The trailing space is an explicit v(): a block's `below` is dropped when the
  // answer line is the last thing in a part, which it almost always is.
  block(width: 100%, above: 1.3em, below: 0pt,
    align(right, box[#label#h(0.3em)#box(width: w, stroke: (bottom: 0.4pt + black), inset: (bottom: 1.5pt), ans)]))
  v(0.7em)
}

// Code on the left, a labelled answer area on the right — the "what does this
// loop print?" layout (LaTeX: two minipages, 9cm and 4cm, solution[3.5cm]).
//
//   #part[#code-answer(```scala var c = 'e' …```, [edb])]
//
// `output` may be a raw block (shown unframed, as a verbatim) or any content.
// The row is never split across pages. `gap` is the space left under the row.
#let code-answer(code, output, code-width: 9cm, answer-width: 4cm, height: 3.5cm, indent: 2em, gap: 0pt, label: auto) = {
  let shown = if type(output) == content and output.func() == raw { verbatim(output) } else { output }
  block(breakable: false, grid(columns: (indent, code-width, answer-width), column-gutter: 2em,
    [],
    code,
    context [#(if label == auto { ui("solution-label") } else { label }) #answer(blank: height, shown)]))
  if gap != 0pt { v(gap) }
}
