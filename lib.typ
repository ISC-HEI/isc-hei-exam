//        ___ ____   ____      _   _ _____ ___
//       |_ _/ ___| / ___|    | | | | ____|_ _|     Informatique et
//        | |\___ \| |   ___  | |_| |  _|  | |       systèmes de communication
//        | | ___) | |__|___| |  _  | |___ | |       HEI Sion · HES-SO Valais / mui 2026
//       |___|____/ \____|    |_| |_|_____|___|
//
// isc-hei-exam — written exams and exercise series for the ISC programme.
//
// A Typst port of the ISC LaTeX exam template (Philip Hirschhorn's exam.cls plus
// the ISC `options.tex`). Same geometry, same cover, same question / part /
// subpart machinery, same student + solution dual output.
//
// This file is the package entrypoint and the sole public API: every
// user-callable function lives in a focused module under lib/ and is
// re-exported here, so `#import "@preview/isc-hei-exam:x.y.z": *` is all a
// document needs.
//
//   lib/settings.typ   — geometry knobs, size ladder, colours, version
//   lib/fonts.typ      — font stacks + the "fonts not installed" fallback page
//   lib/i18n.typ       — i18n() string resolution (fr / en / de)
//   lib/state.typ      — document state, counters, the solutions flag
//   lib/points.typ     — points bookkeeping, grade-table(), num-points() …
//   lib/questions.typ  — question(), part(), subpart() and their bonus variants
//   lib/answers.typ    — solution spaces: dotted lines, boxes, answer lines
//   lib/choices.typ    — checkboxes and true/false rows
//   lib/boxes.typ      — title-box, remark-box, leerseite, last-page, helpers
//   lib/code.typ       — framed, numbered source listings
//   lib/headers.typ    — running headers and footers (exam and series)
//   lib/cover.typ      — the exam cover page
//   lib/exam.typ       — isc-exam(): the show rule; series() alias

#import "lib/settings.typ": *
#import "lib/fonts.typ": *
#import "lib/i18n.typ": *
#import "lib/state.typ": *
#import "lib/points.typ": *
#import "lib/questions.typ": *
#import "lib/answers.typ": *
#import "lib/choices.typ": *
#import "lib/boxes.typ": *
#import "lib/code.typ": *
#import "lib/headers.typ": *
#import "lib/cover.typ": *
#import "lib/exam.typ": *
