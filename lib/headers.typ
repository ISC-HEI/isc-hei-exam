// Running headers and footers.
//
// Exam (from the exam preamble):
//   page 1   no header rule, footer: teachers | month | Page 1/N
//   even     header: date (left)              footer: logo (left)   Page n/N (right)
//   odd      header: small-caps title (right) footer: Page n/N (left)   logo (right)
//   last     footer centre: "The end"
// Series (options.tex): header title | Rev. x with rule; footer teachers | course … n|N.

#import "settings.typ": *
#import "state.typ": *

#let rule() = line(length: 100%, stroke: 0.4pt + black)

#let page-of() = context {
  let p = counter(page).get().first()
  let n = counter(page).final().first()
  [#ui("page") #p/#n]
}

#let footer-logo() = context {
  let l = cfg("footer-logo")
  if l == none { none } else { box(width: 2.2cm, l) }
}

#let exam-header = context {
  let p = counter(page).get().first()
  if p > 1 {
    set text(size: size-small)
    if calc.even(p) { align(left, cfg("date")) } else { align(right, smallcaps(cfg("title"))) }
    v(0.45em)   // headheight=6mm: the rule sits at the bottom of the header box
    rule()
  }
}

#let exam-footer = context {
  let p = counter(page).get().first()
  let last = counter(page).final().first()
  rule()
  v(-0.3em)
  set text(size: size-small)
  let cols = (1fr, auto, 1fr)
  if p == 1 {
    grid(columns: cols, align(left, cfg("teachers")), cfg("month"), align(right, page-of()))
  } else {
    let mid = if p == last { text(size: size-normal, ui("the-end")) } else { none }
    if calc.odd(p) {
      grid(columns: cols, align: horizon, align(left, page-of()), mid, align(right, footer-logo()))
    } else {
      grid(columns: cols, align: horizon, align(left, footer-logo()), mid, align(right, page-of()))
    }
  }
}

#let series-header = context {
  set text(size: size-small)
  grid(columns: (1fr, 1fr), align(left, cfg("title")), align(right)[#ui("revision") #cfg("revision")])
  v(-0.55em)
  rule()
}

#let series-footer = context {
  rule()
  v(-0.3em)
  set text(size: size-small)
  let p = counter(page).get().first()
  let n = counter(page).final().first()
  grid(columns: (1fr, 1fr),
    align(left)[#cfg("teachers") #h(0.3em) $bar.v$ #h(0.3em) #emph(cfg("course"))],
    align(right)[#p#h(0.2em)$bar.v$#h(0.2em)#n])
}
