//        ___ ____   ____      _   _ _____ ___
//       |_ _/ ___| / ___|    | | | | ____|_ _|     Informatique et
//        | |\___ \| |   ___  | |_| |  _|  | |       systèmes de communication
//        | | ___) | |__|___| |  _  | |___ | |       HEI Sion · HES-SO Valais
//       |___|____/ \____|    |_| |_|_____|___|
//
// Sample written exam — the Typst counterpart of exam-sample.tex from the ISC
// LaTeX teaching templates.
//
//   typst compile exam.typ                                   → student version
//   typst compile --input solutions=true exam.typ exam-sol.pdf → solutions
//
// Questions, parts and subparts are flat, sibling calls (like \question /
// \part / \subpart in exam.cls); a plain #pagebreak() between them works.

#import "@preview/isc-hei-exam:0.1.0": *

#show: isc-exam.with(
  title: [Test intermédiaire],
  course: [101.1 -- Programmation impérative],
  date: [27.10.2022],
  month: [Octobre 2022],
  teachers: [Dr P.-A. Mudry],
  revision: [Rev 1.04$omega$],
  lang: "fr",
  expected-total: 50,   // a red note appears on the cover if the points do not add up
  logo-width: 8.5cm,
  logo-pos: (x: 1.2cm, y: 5mm),
  cover-top-space: 1.5cm,
  name-fields: (labels: ([Nom :], [Prénom :]), x: 21mm, y: 10.7mm, gap: 8mm, width: 8cm, size: 12pt),
  instructions: [
    #text(size: 12pt)[*Consigne : *]
    #v(0.35em)
    Lisez attentivement la donnée et répondez de manière *lisible* aux questions. Vous avez droit pour cet examen à un aide-mémoire de 1 pages (1 feuille recto). Aucun moyen électronique n'est permis.
    #v(0.35em)
    Un conseil : ne restez pas bloqués sur une question. Répondez tout d'abord aux questions avec lesquelles vous êtes à l'aise et revenez ensuite aux questions posant problème. Le barème indiqué est indicatif.
  ],
)

// ═══════════════════════════════════════════════════════════════════════════
#question[Short questions]
Cette question est séparée en plusieurs exercices indépendants. Le nombre de point pour chaque exercice est indiqué dans la marge.

// ───────────────────────────────────────────────────────────────────────────
#part(4)
Soient les déclarations suivantes:

```scala
val foo : Int = 0xBABA
val foobar : Float = 3.825f
val baz : String = "y"
```

Les expressions suivantes sont correctes. Donnez le *type* et la *valeur* des expressions suivantes.

// ───────────────────────────────────────────────────────────────────────────
#short-answers(
  (`(foobar + - foobar).toByte`, [Byte, 0]),
  (`(foo & 0xFF0).toHexString`, [String, "ab0"]),
  (`(((foo >> 4) << 4) | 0xE).toHexString`, [String, "babe"]),
  (`(foo^foo).toShort`, [Short, 0]),
  (`((foobar * 100).toInt / 100.0f)`, [Float, 3.82f]),
  (`if(foo < 0xFFFF) 'a' else 'b'`, [Char, 'a']),
  (`if(true) '1' + baz else baz + '1'`, [String, "1y"]),
  (`baz + ('d' + 1.9).toChar + ('t'-1).toChar`, [String, "yes"]),
)

// ───────────────────────────────────────────────────────────────────────────
#part(1)
Quel est le contenu de `r` après l'exécution du code ci-dessous :

```scala
val s: String = "TikTok"
val r: String = StringUtils.charAt(s, StringUtils.length(s)-2) +
"" + StringUtils.charAt(s, 2)
```

#answer(1cm)[`"ok"`]

// ───────────────────────────────────────────────────────────────────────────
#part(1)
Soit le code suivant :

```scala
val a : Boolean = ...
val b : Boolean = a || !a
```

Quelle est la valeur de `b` ?
#choices(inline: true, [Elle dépend du contenu de `a`], correct[`true`], [`false`])

// ───────────────────────────────────────────────────────────────────────────
#bonus-part(2)
Écrivez le code (sans fonction) permettant d'écrire tous les multiples de 79 plus grands que 1 et plus petits que 1000 sur la console.

#answer(1fr)[
  ```scala
  for (i: Int <- 1 until 1000; if i % 79 == 0)
      println(i)
  ```
]

#pagebreak()

// ───────────────────────────────────────────────────────────────────────────
#part(4)
Vrai ou faux ?
#v(2.3em)
#true-false(
  is-true[`(255+1).toByte == (0xFFFF+1).toShort`],
  is-false[Un générateur de séquence peut générer des `Double`],
  is-true[`0 to 10` est une séquence plus longue que `1 until 11`],
  is-true[`\` est le caractère d'échappement],
  is-false[Un programme qui compile fonctionne toujours correctement],
  is-true[Le compilateur détecte les erreurs de type],
  is-false[`println()` est une fonction qui retourne un `String`],
  is-false[Dans l'expression `if(foo) a else b`, `a` et `b` doivent être de même type],
)
#v(1cm)

// ═══════════════════════════════════════════════════════════════════════════
#question(points: 8)[Loops analysis]
Que vont afficher *exactement* les boucles suivantes sur la console ?

// ───────────────────────────────────────────────────────────────────────────
#part[#code-answer(
  ```scala
  var foo: Int = 3
  var bar: Int = 8
  var i : Int = 8

  do {
      bar -= bar / (i>>1)
      foo += 1 & 0
      println(bar + foo + 1)
  } while (foo + 1 < bar)
  ```,
  ```
  10
  9
  8
  ```,
  gap: 7mm,
)]

// ───────────────────────────────────────────────────────────────────────────
#part[#code-answer(
  ```scala
  var j = 6
  var i = 0
  while (i != j) {
      print(i + " " + j + " * ")
      i += 1
      j -= 1
  }
  ```,
  ```
  0 6 * 1 5 * 2 4 *
  ```,
  gap: 7mm,
)]

// ───────────────────────────────────────────────────────────────────────────
#part[#code-answer(
  ```scala
  var a: Int = 0xf0
  var t: String = ""
  while (a != 0) {
    t = (if (a % 2 == 0) '0' else '1') + t
    a /= 2
  }
  print(t)
  ```,
  ```
  11110000
  ```,
  gap: 7mm,
)]

// ───────────────────────────────────────────────────────────────────────────
#part[#code-answer(
  ```scala
  // println(5)
  for (i: Int <- 3 to 7){
      print(s"${i-1*2/3} ")
  }
  ```,
  ```
  3 4 5 6 7
  ```,
  gap: 7mm,
)]

// ═══════════════════════════════════════════════════════════════════════════
#question[EBNF grammars]

// ───────────────────────────────────────────────────────────────────────────
#part
Soit la grammaire suivante pour `exp`

```
factor ::= 'x' | 'y' | 'z' | parexpr
parexpr ::= '(' exp ')'
op ::= '+' | '-'
exp ::= (factor op exp) | factor
```

// ───────────────────────────────────────────────────────────────────────────
#subpart(1)
Donnez une production valide la plus courte possible pour `exp`.
#answer(1cm)[x ou alors y ou alors z]

// ───────────────────────────────────────────────────────────────────────────
#subpart(1)
Donnez une production utilisant chacune des règles de la grammaire.
#answer(1cm)[`x + (z-y)`]

// ───────────────────────────────────────────────────────────────────────────
#subpart(1)
Donnez une production de `exp` utilisant au moins deux fois la règle `parexpr`.

#answer(1cm)[`((x + x) - (y + z))`]

// ───────────────────────────────────────────────────────────────────────────
#part(3)
Écrivez la description EBNF de la grammaire _even-integer_ qui reconnaît uniquement les entiers pairs. Par exemple, dans cette grammaire -6 et 34 sont valides alors que 3 et -23 ne le sont pas. On considère également que 0 et -0 sont valides.

#answer(1fr)[
  ```
  sign ::= '+' | '-'
  even-digit ::= '0' |'2' |'4' |'6' |'8'
  digit ::= even-digit | '1' | '3' | '5' | '7' |'9'
  even-integer ::= [sign] {digit} even-digit
  ```
]

#pagebreak()

// ═══════════════════════════════════════════════════════════════════════════
#question[Code comprehension]

Analysez la fonction suivante puis répondez aux questions ci-dessous.

```scala
def isL(x: Char): Boolean = {
    if (x >= 'a' && x <= 'z') true else false
}

def isU(x: Char): Boolean = {
    if (x >= 'A' && x <= 'Z') true else false
}

def le(x: Char): Boolean = {
    isU(x) || isL(x)
}

def bar(word: String): Int = {
    var p: Int = 0

    for (i <- word) {
      if (!le(i))
        return p

      p += 1
    }
    return -1
}
```

// ───────────────────────────────────────────────────────────────────────────
#part(2)
Expliquez avec des phrases à quoi sert la fonction `bar` ci-dessus.

#answer(3cm)[
  La fonction sert à trouver la position du premier caractère de la chaîne qui n'est pas une lettre minuscule ou majuscule, par exemple un chiffre ou un espace par exemple. Si la chaîne est composée uniquement de lettres ou elle est vide, la fonction retourne -1.
]

// ───────────────────────────────────────────────────────────────────────────
#part(1)
Donnez *deux exemples* complets d'utilisation de `bar` permettant de démontrer votre explication.

#answer(2cm)[
  Exemple 1 : `bar("Hello World")` retourne 5 et `bar("foo")` retourne -1.
]

// ═══════════════════════════════════════════════════════════════════════════
#question[Writing functions]

// ───────────────────────────────────────────────────────────────────────────
#part(2)
Écrivez une fonction nommée `foo` qui prend un `Double` nommé $x$ en argument et qui retourne la valeur
$ italic("foo")(x) = (3x^2 + italic("sin")(x) - 3) / x^3 $

#answer(5cm)[
  ```scala
  def foo(x: Double) : Double = {
      return (3*x*x + math.sin(x) - 3) / (x*x*x)
  }
  ```
]

// ───────────────────────────────────────────────────────────────────────────
#part(2)
Écrivez une fonction retournant, à partir d'un nombre de jours entiers, le nombre correspondant de secondes.

#answer(6cm)[
  ```scala
  def nSeconds(days: Int) : Int = {
      return days * 60 * 60 * 24
  }
  ```
]

// ───────────────────────────────────────────────────────────────────────────
#part()

// ───────────────────────────────────────────────────────────────────────────
#subpart(3)
Écrivez une fonction nommée `factorFinder` qui affiche sur la console tous les diviseurs entiers (sans lui-même ni 1) d'un nombre entier passé en argument.

Si le nombre n'a pas de diviseur (à part lui-même et 1 s'entend), affichez que c'est un nombre premier. *Par simplification, on considère que la fonction ne recevra que des nombres >= 3.* Exemple:
```scala
factorFinder(12) -> affiche "The whole dividers of 12 are : 6 4 3 2 "
factorFinder(54) -> affiche "The whole dividers of 54 are : 27 18 9 6 3 2 "
factorFinder(51) -> affiche "The whole dividers of 51 are : 17 3 "
factorFinder(3)  -> affiche "The whole dividers of 3 are : 3 is prime !"
factorFinder(541) -> affiche "The whole dividers of 541 are : 541 is prime !"
```

// A trailing 1fr answer is hoisted out of the subpart by the library, so the
// bonus subpart below still fits on this page (LaTeX \fill semantics).
#answer(1fr)[
  ```scala
  def factorFinder(n: Int): Unit = {
      print(s"The whole dividers of $n are : ")

      var nDividers = 0

      for (i <- n - 1 until 1 by -1) {
              if (n % i == 0) {
              print(s"$i ")
              nDividers +=1
          }
      }

      if(nDividers == 0)
          print(s"$n is prime !")
  }
  ```
]

// ───────────────────────────────────────────────────────────────────────────
#bonus-subpart(1)
Dans le code ci-dessus, on constate que le string affiché contient un espace à la fin. Comment pouvez-vous faire pour effacer ce caractère dans la console s'il a déjà été généré ?

#answer(1cm)[Avec l'aide du caractère spécial `\b`]

#pagebreak()

// ═══════════════════════════════════════════════════════════════════════════
#question[String manipulations]
Considérez que vous avez à disposition dans votre code les fonctions suivantes pour manipuler les chaînes de caractères, *et uniquement celles-ci*.

```scala
/** Returns the length (number of letters) of the String s */
def length(s: String) : Int
/** Returns the char at position pos in s */
def charAt(s: String, pos: Int)
```

// ───────────────────────────────────────────────────────────────────────────
#part(3, title: [Progressive strings])
#figure(
  image("figs/ascii.svg", width: 147mm),   // 0.85\textwidth
  caption: [La table ASCII],
)

Écrivez une fonction qui reçoit un `String` en argument (de taille 1 au minimum) et qui vérifie que les lettres dans le `String` sont toutes classées dans l'ordre de la table ASCII. Exemple:
```scala
progressive("ABCD") // Returns true
progressive("Aa") // Returns true
progressive("04Tu") // Returns true
progressive("ba") // Returns false
progressive("cZ") // Returns false
```

#answer(1fr)[
  ```scala
  def progressive(s: String): Boolean = {
      var previous : Char = s.charAt(0)

      for(i <- 1 until s.length){
          if(previous > s.charAt(i)) {
              return false
          }

          previous = s.charAt(i)
      }
      return true
  }
  ```
]

#pagebreak()

// ───────────────────────────────────────────────────────────────────────────
#part(4, title: [Double vowels])

Écrivez la fonction `doubleVowels` qui reçoit un `String` en argument et retourne un `String`. Le `string` retourné correspond au `String` reçu mais avec toutes les voyelles qui ont été doublées. Pour cet exercice les voyelles sont : `a`, `e`, `i`, `o`, `u`, `y`.

On considère par simplification que la chaîne en entrée est toujours en minuscule (donc pas besoin de gérer les lettres majuscules). Exemple:
```scala
doubleVowels("hello") // Returns "heelloo"
doubleVowels("aabb") // Returns "aaaabb"
```

#answer(14cm)[
  ```scala
  def doubleVowels(s:String) : String = {
      var t: String = ""
      for (c <- s) {
          c match {
              case 'a'|'e'|'i'|'o'|'u'|'y' =>
                  t = t + c + c
              case _ =>
                  t += c
          }
      }
      return t
  }

  // Other solution
  def doubleVowels(s:String) : String = {
      var t: String = ""
      for (c <- s) {
          t += c match {
              case 'a'|'e'|'i'|'o'|'u'|'y' =>
                  c + "" + c
              case _ =>
                  c
          }
      }
      return t
  }
  ```
]

// ───────────────────────────────────────────────────────────────────────────
#part(4, title: [No triples])
Le clavier de votre ordinateur est défectueux: quand vous tapez 2x de suite la même touche, il écrit 3x de suite le même caractère !

Écrivez la fonction `noTriples` qui corrige cette erreur dans la chaîne passée en argument. Notez que cette fonction n'interagit pas avec la console. Exemple:
```scala
"J'ai fait cettte illlusion" devient "J'ai fait cette illusion"
```

#answer(15cm)[
  ```scala
  def noTriples(s:String) : String = {
      var t: String = ""
      var last: Char = 0
      var count: Int = 0

      for (c <- s) {
          if (last == c) {
              count += 1
          } else {
              count = 0
          }

          if (count != 2) {
              t += c
          }

          last = c
      }
      return t
  }
  ```
]

#pagebreak()

// ═══════════════════════════════════════════════════════════════════════════
#question(points: 5)[Too fast, too furious]
Afin d'améliorer la sécurité sur les routes, les pandores valaisans vont installer un nouveau radar ultra moderne. Ce radar est en effet capable de calculer la vitesse moyenne entre deux points séparés par une certaine distance.

Une infraction est alors constatée si la vitesse moyenne du véhicule est supérieure à la limitation de vitesse en cours.

Écrivez les fonctions suivantes :

- `def averageSpeed(timeOne : Double, timeTwo : Double, distance : Double)` retournant la vitesse moyenne entre les deux radars. Les deux paramètres de temps sont en secondes (remarque : seule la différence entre les deux temps est importante) et la valeur de retour doit être en km/h. La distance entre les deux radars est donnée en mètres.

- `isFaster`, un prédicat prenant comme arguments la vitesse du chauffeur et la limitation de vitesse et qui retourne si le chauffeur est en dehors des limitations.

- `getFineAmount(driverSpeed : Double, maxSpeed : Int)` retournant la valeur de l'amende que le chauffeur devra payer en cas d'infraction.

Pour le dernier point, le montant de l'amende est calculé comme suit :

- une déduction de 5 % doit être faite sur la vitesse mesurée. Arrondissez le résultat de cette déduction à l'unité (ex. 3.4 donne 3 et 3.6 donne 4).

- la facture s'élèvera à 60.- par tranche entamée de 10 km/h supérieurs à la limitation. Ainsi, le montant de l'amende doit être arrondi à la dizaine supérieure (23 km/h en trop vont être facturés comme 30 km/h).

#pagebreak()

#indent[
  Votre solution:
  #answer(1fr, style: "box")[
    ```scala
    def averageSpeed(time1: Double, time2: Double, distance: Double) = (distance / (time2 - time1)) * 3.6
    def isFaster(speed: Double, maxSpeed: Double) = speed > maxSpeed

    def getFineAmountSol1(speed: Double, maxSpeed: Int) = {
      val realSpeed = ((speed - speed * 5.0 / 100.0) + 0.5).toInt
      var price = 0
      var s = realSpeed - maxSpeed
      while (s > 0) {
        price += 60
        s -= 10
      }
      price
    }

    // Other solution
    def getFineAmountSol2(speed: Double, maxSpeed: Int) = {
      val realSpeed = ((speed - speed * 5.0 / 100.0) + 0.5).toInt
      val diff = realSpeed - maxSpeed

      if (diff % 10 == 0)
        diff / 10 * 60
      else if (diff > 0)
        ((diff / 10) + 1) * 60
      else 0
    }
    ```
  ]
]

#pagebreak()

#last-page()
