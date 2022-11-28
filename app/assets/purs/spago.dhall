{ name = "my-project"
, dependencies =
    [ "aff"
    , "affjax"
    , "affjax-web"
    , "argonaut-core"
    , "arrays"
    , "console"
    , "effect"
    , "either"
    , "elmish"
    , "elmish-hooks"
    , "elmish-html"
    , "foldable-traversable"
    , "foreign-object"
    , "functions"
    , "js-date"
    , "maybe"
    , "nullable"
    , "ordered-collections"
    , "prelude"
    , "tuples"
    , "undefined-is-not-a-problem"
    , "unsafe-coerce"
    ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
