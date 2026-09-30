// Source listings: the `listings` + `mdframed` look of options.tex.
//
// A fenced block with a language (```scala …```) is the LaTeX `scala`
// environment: grey rounded frame, line numbers outside the frame on the left.
// A fenced block without a language is `verbatim_lst`: same frame, no numbers.
// The wrappers below select the other variants for the block(s) they enclose:
//
//   #small-listing[```scala …```]   small_scala_frame  (\scriptsize, numbered)
//   #verbatim[``` … ```]            plain \begin{verbatim} (no frame, no numbers)
//   #visible-spaces[``` … ```]      verbatim_lst_spaces (spaces shown as ␣)
//   #doclisting[``` … ```]          doclisting (\scriptsize, no frame)
//   #real-verb("…")                 real_verb (\scriptsize, indentation kept)
//
// The "Listing continues on next page…" notes of mdframed are not reproduced:
// Typst offers no hook on the fragments of a broken block.

#import "settings.typ": *
#import "fonts.typ": raw-font, body-font

#let listing-default = (numbers: auto, size: auto, frame: true, spaces: false)
#let listing-state = state("isc-listing", listing-default)

#let listing(numbers: auto, size: auto, frame: true, spaces: false, body) = {
  listing-state.update((numbers: numbers, size: size, frame: frame, spaces: spaces))
  body
  listing-state.update(listing-default)
}
#let small-listing = listing.with(size: size-scriptsize)
#let verbatim = listing.with(frame: false, numbers: false)
#let visible-spaces = listing.with(spaces: true)
#let doclisting = listing.with(frame: false, numbers: false, size: size-scriptsize)
#let real-verb(code, lang: none, size: size-scriptsize) = listing(size: size, numbers: false, raw(code, block: true, lang: lang))

// Show rules installed by isc-exam(): `show: listing-rules`.
#let listing-rules(doc) = {
  // \texttt at the Bera Mono 0.85 scale. Typst's raw already shrinks its text to
  // 0.8em, so the factor is applied on top of that (0.85 / 0.8).
  let raw-size = listing-scale / 0.8 * 1em
  set raw(theme: "../assets/isc-exam.tmTheme")
  show raw.where(block: false): set text(font: raw-font, size: raw-size)

  show raw.where(block: true): it => context {
    let st = listing-state.get()
    let numbered = if st.numbers == auto { it.lang != none } else { st.numbers }
    let rows = it.lines.map(l => {
      if numbered {
        place(top + left, dx: -(listing-numbersep + 1.6em), dy: 0.1em,
          box(width: 1.6em, align(right,
            text(font: body-font, size: listing-numbers-size, fill: listing-numbers, str(l.number)))))
      }
      // An empty line would collapse to zero height in the stack.
      if l.text == "" { hide[.] } else { l }
    })
    let content = {
      set text(font: raw-font, size: if st.size == auto { raw-size } else { listing-scale * st.size })
      set par(justify: false)
      show " ": if st.spaces { text[␣] } else { " " }
      // LaTeX keeps the 12pt baselineskip of the body for 8.5pt code.
      stack(dir: ttb, spacing: listing-line-gap, ..rows)
    }
    if st.frame {
      block(width: 100%, fill: listing-back, stroke: 0.5pt + listing-frame, radius: listing-radius,
        inset: (x: 8pt, top: 6pt, bottom: 8pt), above: listing-above, below: listing-below, breakable: true, content)
    } else {
      block(width: 100%, above: 0.6em, below: 0.6em, breakable: true, content)
    }
  }
  doc
}
