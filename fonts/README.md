# Fonts

The exam template is set in **Source Sans 3**. The Typst web app has it; a local
`typst` may not. This script downloads the ISC font bundle shared with the other ISC
Typst repositories and installs it for the current user:

```bash
bash fonts/install_fonts.sh        # Linux: ~/.local/share/fonts, macOS: ~/Library/Fonts
```

The bundle also carries **Source Sans Pro** (the name used by the Typst web editor),
Fira Code, Inria Sans and the math fonts of the ISC report templates. Code listings
use DejaVu Sans Mono, which ships with Typst.

All these fonts are released under the [SIL Open Font License](https://openfontlicense.org/),
reproduced in [ofl.md](ofl.md). The fonts are not part of the published package.
