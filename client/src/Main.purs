module Main where

import Prelude

import Effect (Effect)
import Elmish.Boot (defaultMain)
import Elmish.HTML.Styled as H
import Pages.Charts as Charts

main :: Effect Unit
main = defaultMain
  { def:
      { init: pure unit
      , update: \_ msg -> absurd msg
      , view: const $ const view
      }
  , elementId: "app"
  }
  where
    view =
      H.div "pt-3 px-3"
      [ H.h1 "" "Fitness tracker"
      , Charts.view
      ]
