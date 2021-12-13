{ name = "transity"
, dependencies =
  [ "aff"
  , "ansi"
  , "argonaut-codecs"
  , "argonaut-core"
  , "arrays"
  , "bigints"
  , "console"
  , "control"
  , "datetime"
  , "debug"
  , "effect"
  , "foldable-traversable"
  , "foreign"
  , "foreign-object"
  , "format"
  , "formatters"
  , "functions"
  , "lists"
  , "maybe"
  , "newtype"
  , "node-buffer"
  , "node-fs"
  , "node-path"
  , "node-process"
  , "nullable"
  , "ordered-collections"
  , "partial"
  , "prelude"
  , "psci-support"
  , "rationals"
  , "result"
  , "spec"
  , "strings"
  , "transformers"
  , "tuples"
  , "unfoldable"
  , "yaml-next"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
, license = "AGPL-3.0-or-later"
, repository = "https://github.com/feramhq/transity"
}
