// Points bookkeeping.
//
// Every question / part / subpart emits a `metadata` record labelled
// <isc-points> (see questions.typ). The cover's grade table and the question
// headings sum those records with query(), so totals are derived from the
// document and never typed by hand — the Typst equivalent of exam.cls's
// `addpoints` machinery.

#import "settings.typ": *
#import "state.typ": *

// Half a point: #part(points: 2 + half) renders as "2½".
#let half = 0.5

// Format a point value the way exam.cls's \half does: 3, 2½, ½.
#let fmt-points(p) = {
  if p == none { return "" }
  let i = calc.floor(p)
  let f = p - i
  if f == 0 { str(int(p)) }
  else if calc.abs(f - 0.5) < 0.001 { (if i > 0 { str(i) } else { "" }) + "½" }
  else { str(p) }
}

// All points records of the document (inside `context`).
#let points-records() = query(<isc-points>).map(m => m.value)

#let sum-points(records) = records.map(r => r.points).filter(p => p != none).sum(default: 0)

// Total of one question: for a normal question, its own points plus those of
// its non-bonus parts and subparts; for a bonus question, everything it holds.
#let question-total(qid, bonus: false) = {
  let rs = points-records().filter(r => r.qid == qid)
  if bonus { sum-points(rs) } else { sum-points(rs.filter(r => not r.bonus)) }
}

// \numquestions, \numpoints, \numbonuspoints (inside `context`).
#let num-questions() = points-records().filter(r => r.kind == "question" and not r.bonus).len()
#let num-points() = sum-points(points-records().filter(r => not r.bonus))
#let num-bonus-points() = sum-points(points-records().filter(r => r.bonus))

// Barème consistency: a question carries its points either on the question
// itself or on its parts / subparts, never both; the same holds for a part and
// its subparts. Returns the labels of the offending items (inside `context`).
#let points-conflicts() = {
  let rs = points-records()
  let out = ()
  for q in rs.filter(r => r.kind == "question") {
    let inner = rs.filter(r => r.qid == q.qid and r.kind != "question")
    let qlabel = [#ui("question") #q.number]
    if q.points != none and inner.any(r => r.points != none) { out.push(qlabel) }
    let part-i = 0
    let part-has-points = false
    let flagged = false
    for r in inner {
      if r.kind == "part" { part-i += 1; part-has-points = r.points != none; flagged = false }
      else if r.points != none and part-has-points and not flagged {
        out.push([#qlabel #numbering(cfg("part-numbering", default: "(a)"), part-i)])
        flagged = true
      }
    }
  }
  out
}

// The rows of the grade table: one per numbered question.
#let grade-rows() = {
  let rs = points-records()
  rs.filter(r => r.kind == "question" and not r.bonus).map(q => (
    title: if q.title != none { q.title } else { [#ui("question") #q.number] },
    points: sum-points(rs.filter(r => r.qid == q.qid and not r.bonus)),
    bonus: sum-points(rs.filter(r => r.qid == q.qid and r.bonus)),
  ))
}

// \gradetable[v][questions] (mode: "simple") or \combinedgradetable[v][questions]
// (mode: "combined", adds the Bonus column). `auto` picks combined as soon as
// any bonus points exist.
#let grade-table(mode: auto) = context {
  let rows = grade-rows()
  let combined = mode == "combined" or (mode == auto and rows.any(r => r.bonus > 0))
  let cells(a, b, c, d) = if combined { (a, b, c, d) } else { (a, b, d) }
  let total-points = rows.map(r => r.points).sum(default: 0)
  let total-bonus = rows.map(r => r.bonus).sum(default: 0)
  table(
    columns: if combined { 4 } else { 3 },
    align: center + horizon,
    stroke: 0.4pt + black,
    inset: (x: 7pt, y: 5.85pt),   // row pitch 6.44mm (measured)
    ..cells(ui("grade-question"), ui("grade-points"), ui("grade-bonus"), ui("grade-score")),
    ..rows.map(r => cells(r.title, fmt-points(r.points), fmt-points(r.bonus), [])).flatten(),
    ..cells(ui("grade-total"), fmt-points(total-points), fmt-points(total-bonus), []),
  )
}

// "This exam has N questions, for a total of P points."
#let exam-summary() = context {
  ui("exam-summary", params: (n: num-questions(), p: fmt-points(num-points())))
}
