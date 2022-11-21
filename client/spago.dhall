{ name = "my-project"
, dependencies = [ "console", "effect", "elmish", "elmish-html", "prelude" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
