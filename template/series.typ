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

#part[`3 % 4` #answer-line[Int]]
#part[`(10 >> 2)  & 2` #answer-line[Int]]
#part[`true && (n < 5)` #answer-line[Boolean]]
#part[`"Exercise" + "3.1f"` #answer-line[String]]
#part[`if(n > 43) 4.0 else 2.0` #answer-line[Double]]

// ═══════════════════════════════════════════════════════════════════════════
#question[
  Soient les déclarations suivantes :
  ```scala
  val n: Int = 10; val p: Int = 4
  val q: Long = 2; val x: Float = 1.76f;
  ```

  Donnez le type *ainsi que* la valeur des expressions suivantes :
]

#part[`n+q` #answer-line[Long, 12]]
#part[`n < p` #answer-line[Boolean, false]]
#part[`n % p + q` #answer-line[Long, 4]]
#part[`n+x` #answer-line[Float, 11.76f]]
#part[`n >= p` #answer-line[Boolean, true]]
#part[`n > q + 8` #answer-line[Boolean, false]]

#pagebreak()

// ═══════════════════════════════════════════════════════════════════════════
#question[
  Quelle est la valeur de `x` _après_ l'exécution des instructions suivantes ?
]

#part[`var x: Int = if (30 > -30) 10 % 3 else 10 % 5` #answer-line[1]]
#part[`var x: Double = 0.1; x *= 45.3` #answer-line[4.53]]
#part[`var x: Int = 10; x ^= 3` #answer-line[9]]
#part[`var x: Int = 0xc0f0; var y: Int = 0x0a0e; x |= y` #answer-line[0xcafe]]
#part[`var x: Int = 10; x /= 3` #answer-line[3]]
#part[`var x: String = "Hello"; var y: String = "toto"; x+=y` #answer-line["Hellototo"]]
#part[`var x: String = "Hello" + 3 + 4` #answer-line["Hello34"]]
#part[`var x: String = "Hello" + (3 + 4)` #answer-line["Hello7"]]
#part[`var x: Double = 3.0; x /= 3.0` #answer-line[1.0]]

// ═══════════════════════════════════════════════════════════════════════════
#question[
  Lesquelles de ces assignations sont valides ?
]

#true-false[`val a: Int = 3.2`][false]
#true-false[`val b: Double = 4`][true]
#true-false[`val c: Int = (3 << 2.1).toByte`][false]
#true-false[`val d: Long = (121.22f).toLong`][true]
#true-false[`val e: Int = (24 / 21.11).toInt`][true]
#true-false[`val f: Char = 'c'+1;`][false]
#true-false[`val g: Float = (3 / 4.2);`][false]
#true-false[`val h: Boolean = (f > g) & 2;`][false]
#true-false[`val i: Boolean = (e >> f) < d;`][true]
#true-false[`val j: Boolean = (a == c);`][true]

// ═══════════════════════════════════════════════════════════════════════════
#question[
  Écrivez, lorsque cela est possible, les assignations suivantes dans leur forme courte:
]

#part[`x = x-1;` #answer-line[x-=1]]
#part[`x = x+1;` #answer-line[x+=1]]
#part[`x = x*4;` #answer-line[x\*=4]]
#part[`x = x + "toto";` #answer-line[x += ''toto'']]
#part[`x = -2;` #answer-line[x = -2, pas de forme courte]]
#part[`x = x / 10;` #answer-line[x /= 10]]
#part[`x = 10 / x;` #answer-line[x = 10 / x, pas de forme courte]]

// ═══════════════════════════════════════════════════════════════════════════
#question[
  Les parenthèses sont là surtout pour nous faciliter la lecture. Un compilateur n'a pas besoin de parenthèses. Ajoutez des parenthèses aux expressions suivantes selon la priorité des opérateurs appliquée par le compilateur.
]

#part[`+ a < ~ a`]
#part[`-30 - 20 / 2 * 10`]
#part[`-x != y + 3 * 2`]
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

#part[
  A l'aide des opérateurs vus au cours, faites en sorte d'afficher sur la console le contenu de la variable `foo` sur la console comme suit :

  ```
  The value in hex is 0xface
  ```
]

#part[
  ~ [#h(0.15em)*Optionnel* ] Un peu plus difficile. Sans vous servir de votre ordinateur, écrivez le code pour faire en sorte d'afficher la valeur binaire comme suit. #warning-sign() Attention aux espaces~#warning-sign() :

  ```
  In binary it's 0b1111 1010 1100 1110
  ```

  #solution-or-box(8cm)[
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
]

// ═══════════════════════════════════════════════════════════════════════════
#question[
  Soient les variables suivantes :
  ```scala
  val a: Int = 3; val b: Byte = 2; val c: Char = 10; val d: Double = 4.5f;
  ```

  Quel est le type des expressions suivantes ?
]

#subpart[`a+b` #answer-line[Int]]
#subpart[`(d + b).toShort` #answer-line[Short]]
#subpart[`d * a` #answer-line[Double]]
#subpart[`c / b` #answer-line[Int]]
#subpart[`a+b+c+d` #answer-line[Double]]
