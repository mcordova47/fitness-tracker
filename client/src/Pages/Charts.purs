module Pages.Charts
  ( view
  )
  where

import Prelude

import Api as Api
import Components.Recharts.Line (line, monotone)
import Components.Recharts.LineChart (lineChart)
import Components.Recharts.ResponsiveContainer (pixels, responsiveContainer)
import Data.Array (mapMaybe, (!!))
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Elmish (ReactElement)
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks

-- POC for charts
view :: ReactElement
view = Hooks.component Hooks.do
  sessions /\ setSessions <- Hooks.useState Nothing

  Hooks.useEffect do
    s <- Api.sessions "Ms1WqYNb" -- TODO: Don’t hardcode id
    liftEffect $ setSessions s

  let
    firstSets =
      sessions <#> mapMaybe \s -> do
        exercise <- s.exercises !! 0
        set <- exercise.sets !! 0
        pure { date: s.date, weight: set.weight }

  Hooks.pure
    case firstSets of
      Just sets ->
        H.div "row" 
        [ H.div "col-12 col-md-6 col-lg-4" $
            H.div "card" $
              H.div "card-body" $
                responsiveContainer { height: pixels 300.0 } $
                  lineChart { data: sets } $
                    line { dataKey: "weight", type: monotone }
        ]
      Nothing ->
        H.empty
