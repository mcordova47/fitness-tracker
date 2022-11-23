module Pages.Charts
  ( view
  )
  where

import Prelude

import Api as Api
import Components.Recharts.Line (dataKeyFunction, line, monotone)
import Components.Recharts.LineChart (lineChart)
import Components.Recharts.ResponsiveContainer (pixels, responsiveContainer)
import Data.Array (foldl, length, mapWithIndex, range, (!!))
import Data.Foldable (for_, maximum)
import Data.JSDate (JSDate)
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (fromMaybe)
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Elmish (ReactElement)
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks

-- POC for charts
view :: ReactElement
view = Hooks.component Hooks.do
  exerciseHistory' /\ setExerciseHistory <- Hooks.useState Map.empty

  Hooks.useEffect do
    sessions <- Api.sessions "Ms1WqYNb" -- TODO: Don’t hardcode id
    for_ sessions \s ->
      liftEffect $ setExerciseHistory $ exerciseHistory s

  Hooks.pure $
    H.div "row" $
      exerciseHistory' # (Map.toUnfoldable :: _ -> Array _) <#> \(kind /\ setHistories) ->
        H.div "col-12 col-md-6 col-lg-4" $
          H.div "card" $
            H.div "card-body"
            [ H.h2 "" kind
            , responsiveContainer { height: pixels 300.0 } $
                lineChart { data: setHistories } $
                  maximum (length <<< _.weights <$> setHistories) # fromMaybe 0 # (_ - 1) # range 0 # mapWithIndex \index _ ->
                    line { dataKey: dataKeyFunction (_.weights >>> (_ !! index) >>> fromMaybe 0.0), type: monotone }
            ]

exerciseHistory :: Array Api.Session -> Map String (Array { date :: JSDate, weights :: Array Number })
exerciseHistory = foldl insertExerciseHistories Map.empty
  where
    insertExerciseHistories history session =
      foldl (insertExerciseHistory session) history session.exercises

    insertExerciseHistory session history exercise =
      Map.insertWith (<>) exercise.kind [{ date: session.date, weights: _.weight <$> exercise.sets }] history

