module Layout.Nav
  ( Props
  , view
  )
  where

import Prelude

import Data.Tuple.Nested ((/\))
import Elmish (ReactElement)
import Elmish.HTML.Styled as H
import Elmish.Hooks ((=/>))
import Elmish.Hooks as Hooks

type Props =
  { activePage :: String
  , userId :: String
  }

view :: Props -> ReactElement
view { activePage, userId } =
  Hooks.useState false =/> \navExpanded setNavExpanded ->
    H.nav "navbar navbar-expand-md navbar-light bg-light" $
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
  where
    navItem page label =
      H.li "nav-item" $
        H.a_ ("nav-link" <> if page == activePage then " active" else "")
          { href: "/workouts/" <> userId <> "/" <> page }
          label

