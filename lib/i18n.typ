// Internationalisation: resolve user-visible strings from i18n.json.

#let langs = json("../i18n.json")

// i18n(lang, key, params: (n: "7"), extra-i18n: (fr: (key: "value")))
// `$name` placeholders in the string are replaced from `params`.
// `extra-i18n` lets a document override or add keys per language.
#let i18n(lang, key, extra-i18n: none, params: (:)) = {
  let langs = langs
  if type(extra-i18n) == dictionary {
    for (lng, keys) in extra-i18n {
      if not lng in langs { langs.insert(lng, (:)) }
      langs.at(lng) += keys
    }
  }
  assert(lang in langs, message: "isc-hei-exam: unknown UI language '" + str(lang) + "' (fr, en, de)")
  let keys = langs.at(lang)
  assert(key in keys, message: "isc-hei-exam: i18n key '" + str(key) + "' does not exist for '" + str(lang) + "'")
  let translation = keys.at(key)
  for (name, value) in params.pairs() {
    translation = translation.replace("$" + name, str(value))
  }
  translation
}
