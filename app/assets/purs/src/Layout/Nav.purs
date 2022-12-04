module Layout.Nav
  ( Props
  , Props'
  , view
  , view'
  )
  where

import Prelude

import Elmish (ReactElement)
import Elmish.HTML.Styled as H
import Elmish.Hooks ((=/>))
import Elmish.Hooks as Hooks

type Props r =
  { currentPath :: String
  , userId :: String
  | r
  }

type Props' r =
  { currentPath :: String
  , links :: Array { label :: String, url :: String }
  , mainUrl :: String
  | r
  }

view :: ∀ r. Props r -> ReactElement
view { currentPath, userId } =
  view'
    { currentPath
    , mainUrl: href "progress"
    , links:
        [ { label: "View progress", url: href "progress" }
        , { label: "Work out", url: href "workout" }
        ]
    , userId
    }
  where
    href page =
      "/" <> userId <> "/workouts/" <> page

view' :: ∀ r. Props' r -> ReactElement
view' { currentPath, links, mainUrl } =
  Hooks.useState false =/> \expanded setExpanded ->
    H.nav "navbar navbar-expand-md navbar-light bg-light" $
      H.div "container-fluid"
      [ H.a_ "navbar-brand"
          { href: mainUrl }
          "Swollercoaster"
      , H.button_ "navbar-toggler"
          { type: "button"
          , onClick: setExpanded (not expanded)
          } $
          H.span "navbar-toggler-icon" H.empty
      , H.div ("collapse navbar-collapse" <> if expanded then " show" else "") $
          H.ul "navbar-nav" $
            links <#> \{ label, url } ->
              H.li "nav-item" $
                H.a_ ("nav-link" <> if url == currentPath then " active" else "")
                  { href: url }
                  label
      ]
