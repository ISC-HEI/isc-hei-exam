// The exam cover page: logo and name fields anchored to the page corners, the
// ruled title block, the "Consigne" title box with the grade table, the tiny
// revision line.

#import "settings.typ": *
#import "state.typ": *
#import "points.typ" as points
#import "boxes.typ": title-box, hrule

// Defaults of the name fields (the tikz overlay of the CS101 exams: 9cm boxes
// centred at x = 6.5cm, at 14mm and 20mm from the top of the page).
#let name-fields-default = (
  labels: auto,          // auto = (ui("name-field"), ui("class-field"))
  x: 2cm,                // left edge, from the page edge
  y: 14mm,               // baseline of the first field, from the page top
  gap: 6mm,              // between fields
  width: 9cm,
  size: size-normal,
)

#let dotted-field(label, width) = box(width: width)[#label#h(0.5em)#box(width: 1fr, baseline: 0pt, repeat([.], gap: 0.3em))]

#let exam-cover(
  instructions: none,
  grade-mode: auto,
  top-space: 3cm,
  logo: none,
  logo-width: 7.5cm,
  logo-pos: (x: 1.4cm, y: 9mm),   // from the top-right corner of the page
  name-fields: (:),
) = context {
  let m = exam-margin
  let nf = name-fields-default + name-fields
  let labels = if nf.labels == auto { (ui("name-field"), ui("class-field")) } else { nf.labels }

  // Overlays, page-anchored like the tikz [remember picture, overlay] nodes.
  if logo != none {
    place(top + right, dx: m.outside - logo-pos.x, dy: logo-pos.y - m.top, box(width: logo-width, logo))
  }
  for (i, label) in labels.enumerate() {
    place(top + left, dx: nf.x - m.inside, dy: nf.y + i * nf.gap - m.top - 0.75em,
      text(size: nf.size, dotted-field(label, nf.width)))
  }

  // \vspace*{top-space} then the ruled title block.
  v(exam-first-page-extra-top + top-space)
  hrule()
  v(1.4em)   // rule → title baseline 11.6mm (measured)
  align(center, {
    set par(leading: 0.55em)
    text(size: size-huge, smallcaps(cfg("title")))
    if solutions-state.get() {
      linebreak()
      text(size: size-Large, ui("solution-caps"))
      linebreak()
      text(size: size-large, style: "italic", cfg("course"))
    } else {
      linebreak()
      text(size: size-Large, style: "italic", cfg("course"))
    }
  })
  v(0.35em)   // title baseline → rule 8.4mm (measured)
  hrule()
  v(2.5cm + 1.8mm)   // \vspace{2.5cm} + the center env's skips (measured: rule → box 28.7mm)

  if instructions != none {
    title-box({
      instructions
      v(5mm)
      align(center, {
        if grade-mode != none { points.grade-table(mode: grade-mode) }
        v(3mm)
        text(size: size-small, points.exam-summary())
        // Markers that were not consumed by structure(): a #part(3) inside a container.
        let stray = query(<isc-marker>).len()
        if stray > 0 {
          v(2mm)
          text(size: size-small, weight: "bold", fill: rgb("#D41367"), ui("stray-markers", params: (n: stray)))
        }
        // Barème check: shown only when the sum of the points differs from expected-total.
        let expected = cfg("expected-total")
        if expected != none and points.num-points() != expected {
          v(2mm)
          text(size: size-small, weight: "bold", fill: rgb("#D41367"),
            ui("total-mismatch", params: (t: points.fmt-points(points.num-points()), e: points.fmt-points(expected))))
        }
      })
      v(3.5mm)
    })
  }
  v(10pt)
  if cfg("revision") != none {
    align(center, text(size: size-tiny, cfg("revision")))
  }
}
