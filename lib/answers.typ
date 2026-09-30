// Answer spaces: dotted lines, empty boxes, framed solutions, answer lines.
//
// Semantics follow exam.cls exactly:
//   solution(height:)            students: blank space of `height`; solutions: framed box
//   solution-or-dotted-lines(h)  students: dotted lines filling h;  solutions: framed box
//   solution-or-lines(h)         students: solid lines filling h;   solutions: framed box
//   solution-or-box(h)           students: empty framed box of h;   solutions: framed box
// `h` is a length or `1fr` (LaTeX \fill: the rest of the page).
//
// About `1fr`: Typst resolves a fractional height against the enclosing
// container. Inside a part body the container is the part itself, so the
// space swallows the rest of the page and anything written after the part
// moves to the next page. LaTeX's \fill is glue: what follows on the same page
// still gets placed and the fill shrinks. To get that behaviour, write the
// answer space AFTER the part / subpart call, at the top level:
//
//   #subpart(points: 3)[Écrivez la fonction ...]
//   #solution-or-dotted-lines(1fr)[...]      ← fills what is left, next subpart may follow
//   #bonus-subpart(points: 1)[...]
//
// Top-level answer spaces indent themselves to the current level automatically.

#import "settings.typ": *
#import "state.typ": *

#let dotted-leader = box(width: 100%, repeat([.], gap: 0.3em))
#let solid-leader = line(length: 100%, stroke: 0.4pt + black)

// A block of `height` filled with `leader` every \linefillheight (0.25in).
#let fill-with(height, leader) = context {
  let ind = top-level-indent()
  align(right, block(width: 100% - ind, height: height, breakable: false, above: 0.6em, below: 0.6em,
    layout(size => {
      let n = calc.max(1, calc.floor(size.height / line-fill-height))
      for i in range(n) {
        place(top + left, dy: (i + 1) * line-fill-height - 0.4em, leader)
      }
    })))
}

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
#let solution(height: none, body) = context {
  if solutions-state.get() { solution-box(body) }
  else if height != none { v(height) }
}

// \begin{solutionordottedlines}[h]
#let solution-or-dotted-lines(height, body) = context {
  if solutions-state.get() { solution-box(body) } else { fill-with(height, dotted-leader) }
}

// \begin{solutionorlines}[h]
#let solution-or-lines(height, body) = context {
  if solutions-state.get() { solution-box(body) } else { fill-with(height, solid-leader) }
}

// \begin{solutionorbox}[h]
#let solution-or-box(height, body) = context {
  if solutions-state.get() { solution-box(body) }
  else {
    let ind = top-level-indent()
    align(right, block(width: 100% - ind, height: height, stroke: solution-stroke + black, breakable: false, above: 0.6em, below: 0.6em))
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
