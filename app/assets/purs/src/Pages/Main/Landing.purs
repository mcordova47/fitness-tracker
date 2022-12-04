module Pages.Main.Landing where

import Prelude

import Elmish (ReactElement)
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks

type Props = {}

view :: Props -> ReactElement
view _ = Hooks.component Hooks.do
  Hooks.pure $
    H.div "container py-4"
    [ H.h1 "" "Welcome"
    , H.p ""
      [ H.text "Swollercoaster helps you track your fitness goals. "
      , H.a_ "" { href: "/workout" } "Click here"
      , H.text " to get started and track your first session!"
      ]
    ]
