// Calibration knobs, shared metrics and colours.
//
// Every value here mirrors a quantity of the LaTeX reference (exam.cls +
// options.tex, 10pt, A4). The LaTeX origin is given in the comment so the knob
// can be re-derived; values marked "measured" were read off the reference PDF
// rather than computed, following the latex-to-typst rule: sample, don't compute.

#let version = toml("../typst.toml").package.version

// ── LaTeX 10pt size ladder ────────────────────────────────────────────────────
#let size-tiny = 5pt          // \tiny
#let size-scriptsize = 7pt    // \scriptsize
#let size-footnotesize = 8pt  // \footnotesize
#let size-small = 9pt         // \small
#let size-normal = 10pt       // \normalsize
#let size-large = 12pt        // \large
#let size-Large = 14.4pt      // \Large
#let size-LARGE = 17.28pt     // \LARGE
#let size-huge = 20.74pt      // \huge
#let size-Huge = 24.88pt      // \Huge

// ── Page geometry ─────────────────────────────────────────────────────────────
// Exam: geometry{twoside, bindingoffset=5mm, left/right=15mm, top=10mm,
// bottom=15mm, headheight=6mm, headsep=7mm, foot=10mm, footskip=9mm,
// includeheadfoot} then \extrawidth{-2mm}, \extraheadheight[0.5cm]{-0.2cm},
// \extrafootheight{-5mm}, \headsep=0.7cm. With includeheadfoot the header and
// footer live INSIDE the LaTeX margins; Typst puts them in the margin, hence
// the larger top/bottom values. Tuned on the reference renders.
// Body bottom measured at 21.5mm from the page bottom on exam3-2025 (which
// uses \extrafootheight{-2mm}); the sample exam uses -5mm, hence 18.5-19mm.
#let exam-margin = (inside: 21mm, outside: 16mm, top: 21mm, bottom: 19mm)
#let exam-first-page-extra-top = 11.7mm     // \extraheadheight[0.5cm]{-0.2cm} + \vspace* offsets (measured on the cover)
#let exam-header-ascent = 5.8mm             // header rule at 15.2mm from the page top (measured)
#let exam-footer-descent = 6.5mm            // footer baseline at ~7.2mm from the page bottom (measured)

// Series: geometry{left/right=20mm, top=9mm, bottom=14mm, headheight=9mm,
// headsep=7mm, foot=10mm, footskip=8mm, includeheadfoot}, one-sided.
#let series-margin = (x: 20mm, top: 30mm, bottom: 22mm)   // title baseline at ~33mm (measured)
#let series-header-ascent = 9mm                             // header rule at ~21mm from the page top
#let series-footer-descent = 6mm

// ── Question tree indentation (measured on exam3-2025.pdf p2) ─────────────────
#let question-indent = 6.3mm        // exam.cls `questions` list indent
#let part-label-width = 6.9mm       // from "(a)" to the part text
#let subpart-label-width = 5.3mm    // from "1)" to the subpart text
#let margin-points-offset = 15.5mm  // from the part label to the left edge of "[3 Pt]"
#let margin-points-width = 14mm

// ── Spacing (LaTeX baselineskip 12pt at 10pt, \parskip 0) ────────────────────
#let body-leading = 0.55em
#let par-spacing = 0.55em
#let question-above = 1.4em
#let question-below = 0.35em
#let part-above = 0.85em
#let part-below = 0.35em
#let subpart-gap = 0.6em      // \subpart item separation (measured on exam3 p3)

// ── Answer spaces ─────────────────────────────────────────────────────────────
#let line-fill-height = 0.25in      // \linefillheight = \dottedlinefillheight
#let answer-line-length-exam = 3cm      // \setlength\answerlinelength{3cm}, both versions
#let answer-line-length-series = 1in    // exam.cls default (series hand-out)
#let answer-line-length-series-sol = 5.5cm  // series preamble sets 5.5cm in answers mode only
#let solution-stroke = 0.4pt        // TheSolution \fbox rule (0.4pt = \fboxrule)

// ── Listings (options.tex, listings + mdframed) ───────────────────────────────
#let listing-back = luma(242)          // mdframed backgroundcolor=black!5   (sampled: #F2F2F2)
#let listing-frame = luma(64)          // mdframed middlelinecolor=black!75  (sampled: #404040)
#let listing-numbers = rgb("#B3B2B3")  // \definecolor{listing-numbers}{HTML}{B3B2B3}
#let listing-radius = 4pt              // roundcorner=4
#let listing-above = 11.5pt            // skipabove=9pt + the paragraph skip (measured: 12pt text→frame)
#let listing-below = 9pt               // skipbelow=0pt, but the frame's outer margin (measured: 15pt frame→text)
#let listing-scale = 0.85              // \usepackage[scaled=0.85]{beramono}
#let listing-numbersep = 15pt          // numbersep=15pt
#let listing-numbers-size = 7pt        // numberstyle=\scriptsize
#let listing-line-gap = 0.6em          // extra gap between code lines → ~12pt pitch (measured)

// ── Misc colours ──────────────────────────────────────────────────────────────
#let url-color = rgb("#0000FF")        // hyperref urlcolor=blue (xcolor rgb blue)
#let todo-color = rgb("#FFFF00")       // svgnames Yellow
#let colored-color = rgb("#D02090")    // svgnames VioletRed
#let watermark-color = luma(230)       // draftwatermark lightness 0.9
#let remark-top = luma(242)            // remarkbox top color=gray!10
#let remark-bottom = luma(230)         // remarkbox bottom color=gray!20
#let shadow-color = luma(150)          // tikz drop shadow, flattened

// ── Programme colours (official ISC majors), for users' own decorations ───────
#let isc-embedded = rgb(152, 199, 191) // Systèmes informatiques embarqués
#let isc-security = rgb(226, 171, 186) // Sécurité informatique
#let isc-networks = rgb(168, 144, 192) // Réseaux et systèmes
#let isc-software = rgb(140, 198, 230) // Informatique logicielle
#let isc-data = rgb(247, 241, 159)     // Ingénierie des données
#let isc-magenta = rgb("#EC008B")      // signature accent (sampled from the LaTeX logo)
