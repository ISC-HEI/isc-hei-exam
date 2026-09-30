// Font configuration and the fallback page shown when the ISC fonts are absent.
// Pattern shared with the isc-hei-* student templates.

// Body: Source Sans Pro in LaTeX (sourcesanspro[default, lining]). Source Sans 3
// is its current name on Google Fonts / local installs; the Typst web app ships
// Source Sans Pro. Both names are listed so either resolves.
#let body-font = ("Source Sans 3", "Source Sans Pro")

// Code: LaTeX uses Bera Mono (beramono, scaled 0.85). DejaVu Sans Mono is the
// same design (Bitstream Vera), is bundled with Typst and available in the web
// app, so listings need no font installation.
#let raw-font = ("DejaVu Sans Mono", "Fira Mono")

// Detect whether the ISC body font is available using a glyph-metric comparison.
// Source Sans has markedly different capital widths from Libertinus Serif
// (always bundled). Equal widths means both names fell back to Libertinus.
// Must be called from within a `context` block (uses measure()).
#let isc-fonts-available() = {
  let probe = "MMMMMMMMMM"
  let isc = measure(text(font: body-font, size: 12pt, probe)).width
  let lib = measure(text(font: ("Libertinus Serif",), size: 12pt, probe)).width
  isc != lib
}

// Warning page rendered instead of the document when the body font is absent.
// Deliberately uses only Libertinus Serif so the page itself renders correctly.
#let missing-fonts-page() = {
  set page(paper: "a4", margin: (x: 3cm, y: 3cm), header: none, footer: none, numbering: none)
  set text(font: ("Libertinus Serif",), size: 11pt, fill: black)
  let accent = rgb("#EC008B")

  align(center + horizon,
    rect(
      width: 100%,
      stroke: (left: 5pt + accent, rest: 0.8pt + luma(200)),
      radius: 4pt,
      inset: (x: 2em, y: 1.8em),
      {
        align(center, text(size: 1.8em, weight: "bold", fill: accent)[⚠ isc-hei-exam — fonts not installed])
        v(1em)
        line(length: 100%, stroke: 0.5pt + luma(220))
        v(1em)
        [The body font required by this template, *Source Sans 3* (or *Source Sans Pro*),
        is not visible to Typst on this system, so the exam cannot be rendered with
        the correct typography and page breaks.]
        v(1.2em)
        [*Install it once*, for instance from #link("https://fonts.google.com/specimen/Source+Sans+3")[Google Fonts]
        or your package manager, then recompile. `typst fonts` lists what Typst sees.]
        v(1.2em)
        text(style: "italic", size: 0.9em, fill: luma(100))[
          Pass `check-fonts: false` to `isc-exam` to render anyway with a fallback font.
        ]
      }
    )
  )
}
