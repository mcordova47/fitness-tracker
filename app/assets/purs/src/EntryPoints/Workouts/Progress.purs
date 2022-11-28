module EntryPoints.Workouts.Progress
  ( boot
  )
  where

import Prelude

import Data.Tuple.Nested ((/\))
import Elmish.Boot (BootRecord)
import Elmish.Boot as Elmish
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks
import Pages.Charts as Charts

type Props =
  { activePage :: String
  , userId :: String
  }

boot :: BootRecord Props
boot = Elmish.boot mkDef
  where
    mkDef { activePage, userId } =
      { init: pure unit
      , update: \_ msg -> absurd msg
      , view: const $ const view
      }
      where
        view = Hooks.component Hooks.do
          navExpanded /\ setNavExpanded <- Hooks.useState false
          Hooks.pure $
            H.div "pt-3 px-3"
            [ H.nav "navbar navbar-expand-md navbar-light bg-light" $
                H.div "container-fluid"
                [ H.a_ "navbar-brand"
                    { href: "/workouts/" <> userId <> "/progress" }
                    "Fitness tracker"
                , H.button_ "navbar-toggler"
                    { type: "button"
                    , onClick: setNavExpanded (not navExpanded)
                    } $
                    H.span "navbar-toggler-icon" H.empty
                , H.div ("collapse navbar-collapse" <> if navExpanded then " show" else "") $
                    H.ul "navbar-nav"
                    [ navItem "progress" "View progress"
                    , navItem "workout" "Work out"
                    ]
                ]
            , Charts.view { userId }
            ]

        navItem page label =
          H.li "nav-item" $
            H.a_ ("nav-link" <> if page == activePage then " active" else "")
              { href: "/workouts/" <> userId <> "/" <> page }
              label
