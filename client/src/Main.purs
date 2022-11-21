module Main where

import Prelude

import Effect (Effect)
import Elmish.Boot (defaultMain)
import Elmish.HTML.Styled as H

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
    view = H.h1 "" "Fitness tracker"
