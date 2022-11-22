{ name = "my-project"
, dependencies = [ "console", "effect", "elmish", "elmish-html", "prelude", "undefined-is-not-a-problem" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
