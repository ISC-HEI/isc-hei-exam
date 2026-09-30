// Boxes and page helpers from options.tex: \titlebox, \remarkbox, \leerseite,
// \lastPage, \turnWarning, \turnpage, \lineSep, \todo, \colored, \bigO, \vspc.

#import "settings.typ": *
#import "state.typ": *
#import "fonts.typ": raw-font

#let hrule() = line(length: 100%, stroke: 0.4pt + black)

// \titlebox: white rounded box, 85% of the line width, with a drop shadow.
// Typst has no shadow primitive, so a grey rectangle is placed behind, offset.
#let title-box(body, width: 85%, shadow: 2.5pt, inset: 10pt, radius: 5pt) = layout(size => {
  let w = if type(width) == ratio { width * size.width } else { width }
  let inner = block(width: w, fill: white, stroke: 0.5pt + black, radius: radius, inset: inset, body)
  let h = measure(inner).height
  align(center, box(width: w + shadow, height: h + shadow, {
    place(top + left, dx: shadow, dy: shadow, rect(width: w, height: h, fill: shadow-color, radius: radius, stroke: none))
    place(top + left, inner)
  }))
})

// \remarkbox: grey gradient box, 75% wide, with a "Remark" tab on its lower right edge.
#let remark-box(body, width: 75%) = context {
  align(center, block(width: width, {
    block(width: 100%, fill: gradient.linear(angle: 90deg, remark-top, remark-bottom),
      stroke: 0.5pt + black, radius: 5pt, inset: 10pt, below: 0pt, body)
    v(-0.85em)
    align(right, pad(right: 12%, box(fill: white, stroke: 0.5pt + black, radius: 5pt, inset: 5pt, smallcaps(ui("remark")))))
  }))
}

// \leerseite: a page that says it was left blank on purpose. Name kept from LaTeX.
#let leerseite() = context {
  pagebreak(weak: true)
  v(1fr)
  hrule()
  align(center)[
    #text(size: size-Large, emph(ui("blank-title"))) \
    #v(-1.5mm) $diamond$ #v(1mm) \
    #ui("blank-text")
  ]
  hrule()
  v(1fr)
  pagebreak()
}

// \lastPage: "The end" between two rules, vertically centred in what is left of the page.
#let last-page() = context {
  v(1fr)
  hrule()
  v(1mm)
  align(center, text(size: size-Large, emph(ui("the-end"))))
  v(2mm)
  hrule()
  v(1fr)
}

// A drawn warning triangle (\warning from fourier-orns).
#let warning-sign(size: 1em) = box(baseline: 0.1em, width: size, height: size, {
  place(polygon(fill: none, stroke: 0.5pt + black, (size * 0.5, 0pt), (size, size * 0.9), (0pt, size * 0.9)))
  place(center + horizon, dy: size * 0.08, text(size: size * 0.6, weight: "bold")[!])
})

// \turnpage: "Turn page →" flushed right at the bottom of the page.
#let turn-page() = context { v(1fr); align(right, emph[#ui("turn-page") $arrow.r$]) }

// \turnWarning: same, with the warning sign, then a page break (nest-safe).
#let turn-warning() = context { v(1fr); align(right, emph[#warning-sign() #ui("turn-page") $arrow.r$]); colbreak() }

// A page break that also works inside a part body (Typst forbids pagebreak()
// inside containers; colbreak() does the same job at any depth).
#let new-page() = colbreak()

// \lineSep: short centred rule separating two language versions.
#let line-sep() = align(center, { v(-1mm); line(length: 6cm, stroke: 0.4pt + black); v(1.5mm) })

// \todo{...} and \colored{...}
#let todo(body) = box(fill: todo-color, inset: 2pt, outset: (y: 1pt))[#smallcaps[TODO]: #emph(body)]
#let colored(body) = box(fill: colored-color, inset: 2pt, outset: (y: 1pt), body)

// \bigO{n^2} — use inside math: $big-o(n^2)$
#let big-o(x) = $cal(O) lr(( #x ))$

// \vspc — a visible space glyph, ␣ (U+2423, present in DejaVu Sans Mono).
#let visible-space() = text(font: raw-font)[␣]

// \inline{code} — plain monospace inline code (same as `code`).
#let inline(code) = raw(code)
