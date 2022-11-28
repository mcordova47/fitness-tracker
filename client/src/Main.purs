module Main where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Elmish.Boot (defaultMain)
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks
import Pages.Charts as Charts
import Pages.WorkOut as WorkOut

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
    view = Hooks.component Hooks.do
      let userId = "Ms1WqYNb" -- TODO: Don’t hardcode id
      page /\ setPage <- Hooks.useState Progress
      navExpanded /\ setNavExpanded <- Hooks.useState false
      
      Hooks.pure $
        H.div "pt-3 px-3"
        [ H.nav "navbar navbar-expand-md navbar-light bg-light" $
            H.div "container-fluid"
            [ H.a_ "navbar-brand"
                { href: "#"
                , onClick: setPage Progress
                }
                "Fitness tracker"
            , H.button_ "navbar-toggler"
                { type: "button"
                , onClick: setNavExpanded (not navExpanded)
                } $
                H.span "navbar-toggler-icon" H.empty
            , H.div ("collapse navbar-collapse" <> if navExpanded then " show" else "") $
                H.ul "navbar-nav"
                [ navItem Progress page setPage "View progress"
                , navItem WorkOut page setPage "Work out"
                ]
            ]
        , case page of
            Progress -> Charts.view { userId }
            WorkOut -> WorkOut.view { userId }
        ]

    navItem itemPage currentPage setPage label =
      H.li "nav-item" $
        H.a_ ("nav-link" <> if itemPage == currentPage then " active" else "")
          { href: "#"
          , onClick: setPage itemPage
          }
          label

data Page
  = Progress
  | WorkOut
derive instance Eq Page
