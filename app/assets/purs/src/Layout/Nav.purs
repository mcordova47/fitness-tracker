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
import Utils.Html (htmlIf)

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
        [ { label: "View progress", url: href "workouts/progress" }
        , { label: "Gains", url: href "measurements/progress" }
        , { label: "Work out", url: href "workouts/workout" }
        ]
    , userId
    }
  where
    href page =
      "/" <> userId <> "/" <> page

view' :: ∀ r. Props' r -> ReactElement
view' { currentPath, links, mainUrl } =
  Hooks.useState false =/> \expanded setExpanded ->
    H.nav "bg-slate-200 dark:bg-slate-800 p-3 flex flex-col gap-2 rounded-sm"
    [ H.div "flex justify-between"
      [ H.div "inline-flex gap-4"
        [ H.a_ "text-lg"
          { href: mainUrl }
          "Swollercoaster"
        , H.div "hidden md:inline-flex gap-3" $
            links <#> \{ label, url } ->
              H.a_ ("pt-0.5" <> if url == currentPath then " underline underline-offset-4" else "")
                { href: url }
                label
        ]
      , H.button_ "md:hidden"
          { type: "button"
          , onClick: setExpanded (not expanded)
          } $
          H.span "fa fa-bars" H.empty
      ]
    , htmlIf expanded $
        H.fragment $
          links <#> \{ label, url } ->
            H.a_ ("pt-0.5" <> if url == currentPath then " underline underline-offset-4" else "")
              { href: url }
              label
    ]
