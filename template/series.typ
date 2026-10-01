//        ___ ____   ____      _   _ _____ ___
//       |_ _/ ___| / ___|    | | | | ____|_ _|     Informatique et
//        | |\___ \| |   ___  | |_| |  _|  | |       systèmes de communication
//        | | ___) | |__|___| |  _  | |___ | |       HEI Sion · HES-SO Valais
//       |___|____/ \____|    |_| |_|_____|___|
//
// Sample exercise series — the Typst counterpart of serie-sample.tex from the
// ISC LaTeX teaching templates.
//
//   typst compile series.typ                                       → hand-out
//   typst compile --input solutions=true series.typ series-sol.pdf  → solutions

#import "@preview/isc-hei-exam:0.1.0": *

#show: series.with(
  solutions: auto,              // true prints the solutions; auto follows --input solutions=true
  title: [Série 2],
  subtitle: [Expressions],
  revision: [1.05],
  course: [101.1 Programmation impérative],
  teachers: [Dr Pierre-André Mudry],
  lang: "fr",
)

// ═══════════════════════════════════════════════════════════════════════════
#question[
  Quel est le type (au sens informatique du terme) des expressions suivantes (on suppose `n` entier) ?
]

// ───────────────────────────────────────────────────────────────────────────
#short-answers(level: "part",
  (`3 % 4`, [Int]),
  (`(10 >> 2)  & 2`, [Int]),
  (`true && (n < 5)`, [Boolean]),
  (`"Exercise" + "3.1f"`, [String]),
  (`if(n > 43) 4.0 else 2.0`, [Double]),
)

// ═══════════════════════════════════════════════════════════════════════════
#question[
  Soient les déclarations suivantes :
  ```scala
  val n: Int = 10; val p: Int = 4
  val q: Long = 2; val x: Float = 1.76f;
  ```

  Donnez le type *ainsi que* la valeur des expressions suivantes :
]

// ───────────────────────────────────────────────────────────────────────────
#short-answers(level: "part",
  (`n+q`, [Long, 12]),
  (`n < p`, [Boolean, false]),
  (`n % p + q`, [Long, 4]),
  (`n+x`, [Float, 11.76f]),
  (`n >= p`, [Boolean, true]),
  (`n > q + 8`, [Boolean, false]),
)

#pagebreak()

// ═══════════════════════════════════════════════════════════════════════════
#question[
  Quelle est la valeur de `x` _après_ l'exécution des instructions suivantes ?
]

// ───────────────────────────────────────────────────────────────────────────
#short-answers(level: "part",
  (`var x: Int = if (30 > -30) 10 % 3 else 10 % 5`, [1]),
  (`var x: Double = 0.1; x *= 45.3`, [4.53]),
  (`var x: Int = 10; x ^= 3`, [9]),
  (`var x: Int = 0xc0f0; var y: Int = 0x0a0e; x |= y`, [0xcafe]),
  (`var x: Int = 10; x /= 3`, [3]),
  (`var x: String = "Hello"; var y: String = "toto"; x+=y`, ["Hellototo"]),
  (`var x: String = "Hello" + 3 + 4`, ["Hello34"]),
  (`var x: String = "Hello" + (3 + 4)`, ["Hello7"]),
  (`var x: Double = 3.0; x /= 3.0`, [1.0]),
)

// ═══════════════════════════════════════════════════════════════════════════
#question[
  Lesquelles de ces assignations sont valides ?
]

#true-false(
  is-false[`val a: Int = 3.2`],
  is-true[`val b: Double = 4`],
  is-false[`val c: Int = (3 << 2.1).toByte`],
  is-true[`val d: Long = (121.22f).toLong`],
  is-true[`val e: Int = (24 / 21.11).toInt`],
  is-false[`val f: Char = 'c'+1;`],
  is-false[`val g: Float = (3 / 4.2);`],
  is-false[`val h: Boolean = (f > g) & 2;`],
  is-true[`val i: Boolean = (e >> f) < d;`],
  is-true[`val j: Boolean = (a == c);`],
)

// ═══════════════════════════════════════════════════════════════════════════
#question[
  Écrivez, lorsque cela est possible, les assignations suivantes dans leur forme courte:
]

// ───────────────────────────────────────────────────────────────────────────
#short-answers(level: "part",
  (`x = x-1;`, [x-=1]),
  (`x = x+1;`, [x+=1]),
  (`x = x*4;`, [x\*=4]),
  (`x = x + "toto";`, [x += ''toto'']),
  (`x = -2;`, [x = -2, pas de forme courte]),
  (`x = x / 10;`, [x /= 10]),
  (`x = 10 / x;`, [x = 10 / x, pas de forme courte]),
)

// ═══════════════════════════════════════════════════════════════════════════
#question[
  Les parenthèses sont là surtout pour nous faciliter la lecture. Un compilateur n'a pas besoin de parenthèses. Ajoutez des parenthèses aux expressions suivantes selon la priorité des opérateurs appliquée par le compilateur.
]

// ───────────────────────────────────────────────────────────────────────────
#part[`+ a < ~ a`]

// ───────────────────────────────────────────────────────────────────────────
#part[`-30 - 20 / 2 * 10`]

// ───────────────────────────────────────────────────────────────────────────
#part[`-x != y + 3 * 2`]

// ───────────────────────────────────────────────────────────────────────────
#part[`a / b * c / d`]

#solution[
  ```
  ((+ a) < (~ a))
  (-30) - ((20 / 2) * 10)
  (-x) != (y + (3 * 2))
  (((a / b) * c) / d)
  ```
]

#pagebreak()

// ═══════════════════════════════════════════════════════════════════════════
#question[
  Vous avez à disposition le code suivant :

  ```scala
  val foo: Int = 0xFACE
  ```
]

// ───────────────────────────────────────────────────────────────────────────
#part
A l'aide des opérateurs vus au cours, faites en sorte d'afficher sur la console le contenu de la variable `foo` sur la console comme suit :

```
The value in hex is 0xface
```

// ───────────────────────────────────────────────────────────────────────────
#part
~ [#h(0.15em)*Optionnel* ] Un peu plus difficile. Sans vous servir de votre ordinateur, écrivez le code pour faire en sorte d'afficher la valeur binaire comme suit. #warning-sign() Attention aux espaces~#warning-sign() :

```
In binary it's 0b1111 1010 1100 1110
```

#answer(8cm, style: "box")[
  ```scala
  val foo: Int = 0xFACE

  println("The value in hex is 0x" + foo.toHexString)

  println("In binary it's 0b"
      + ((foo >> 12) & 0XF).toBinaryString
      + " " + ((foo >> 8) & 0xF).toBinaryString
      + " " + ((foo >> 4) & 0XF).toBinaryString
      + " " + (foo & 0xF).toBinaryString)
  ```
]

// ═══════════════════════════════════════════════════════════════════════════
#question[
  Soient les variables suivantes :
  ```scala
  val a: Int = 3; val b: Byte = 2; val c: Char = 10; val d: Double = 4.5f;
  ```

  Quel est le type des expressions suivantes ?
]

// ───────────────────────────────────────────────────────────────────────────
#short-answers(
  (`a+b`, [Int]),
  (`(d + b).toShort`, [Short]),
  (`d * a`, [Double]),
  (`c / b`, [Int]),
  (`a+b+c+d`, [Double]),
)
