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
    H.div "text-center py-4"
    [ H.h1 "text-3xl" "Welcome"
    , H.p ""
      [ H.text "Stay on track with Swollercoaster! "
      , H.a_ "text-blue-500 underline dark:text-white" { href: "/workout" } "Click here"
      , H.text " to get started and track your first session!"
      ]
    , H.img_ "mt-3 mx-auto"
        { src: assetPath "/logo.png"
        , style: H.css { width: "100%", maxWidth: 400 }
        }
    ]
