// Document-level state shared by every module.
//
// isc-exam() writes the configuration once; helpers read it inside `context`.

#import "i18n.typ": i18n

// Are we printing the solutions? Resolved once by isc-exam().
#let solutions-state = state("isc-exam-solutions", false)

// Document configuration (kind, lang, title, ...). Read with cfg("key").
#let cfg-state = state("isc-exam-cfg", (:))
#let cfg(key, default: none) = cfg-state.get().at(key, default: default)

// UI strings in the document's UI language. Must be called inside `context`.
#let ui(key, params: (:)) = i18n(cfg("ui-lang", default: "fr"), key, extra-i18n: cfg("extra-i18n"), params: params)

// Counters of the question tree.
#let question-counter = counter("isc-question")   // numbered (non-bonus) questions
#let qid-counter = counter("isc-qid")             // every question, bonus included: the join key for points
#let part-counter = counter("isc-part")
#let subpart-counter = counter("isc-subpart")
#let section-counter = counter("isc-section")

// Which label answer-line() repeats: "question" | "part" | "subpart".
#let level-state = state("isc-level", "question")

// Indentation already applied by an enclosing question / part / subpart body
// (0mm at the top level of the document).
#let indent-state = state("isc-indent", 0mm)

// Indent that a top-level element (one written after a question / part /
// subpart call, not inside it) must add to line up with that level's text.
// Inside a body nothing is added: the container already indents.
#let top-level-indent() = {
  import "settings.typ": question-indent, part-label-width, subpart-label-width
  if indent-state.get() > 0mm { return 0mm }
  let lvl = level-state.get()
  if lvl == "part" { question-indent + part-label-width }
  else if lvl == "subpart" { question-indent + part-label-width + subpart-label-width }
  else { question-indent }
}

// Label carried by every points record (see points.typ).
#let points-label = <isc-points>

// --input solutions=true / yes / 1 / on on the command line.
#let truthy(v) = lower(str(v)) in ("1", "true", "yes", "on")

// Precedence: explicit parameter > --input solutions=... > false.
#let resolve-solutions(param) = {
  if param != auto { return param }
  truthy(sys.inputs.at("solutions", default: "false"))
}

// Render `yes` when printing solutions, `no` otherwise.
#let in-solutions(yes, no: none) = context { if solutions-state.get() { yes } else { no } }
