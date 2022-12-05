module Pages.Main.Landing where

import Prelude

import Elmish (ReactElement)
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks
import Utils.Assets (assetPath)

type Props = {}

view :: Props -> ReactElement
view _ = Hooks.component Hooks.do
  Hooks.pure $
    H.div "container text-center py-4"
    [ H.h1 "" "Welcome"
    , H.p ""
      [ H.text "Swollercoaster helps you track your fitness goals. "
      , H.a_ "" { href: "/workout" } "Click here"
      , H.text " to get started and track your first session!"
      ]
    , H.img_ "img-fluid mt-3"
        { src: assetPath "/logo.png"
        , style: H.css { width: "100%", maxWidth: 400 }
        }
    ]
