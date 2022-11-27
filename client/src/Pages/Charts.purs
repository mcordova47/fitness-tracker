module Pages.Charts
  ( view
  )
  where

import Prelude

import Api as Api
import Components.Recharts.CartesianGrid (cartesianGrid)
import Components.Recharts.Line (line, monotone)
import Components.Recharts.LineChart (lineChart)
import Components.Recharts.ResponsiveContainer (pixels, responsiveContainer)
import Components.Recharts.Tooltip (tooltip)
import Components.Recharts.Types.DataKey (dataKeyFunction, dataKeyString)
import Components.Recharts.XAxis (tickFormatter, xAxis)
import Components.Recharts.YAxis (yAxis)
import Data.Array (foldl, length, mapWithIndex, range, (!!))
import Data.Foldable (for_, maximum)
import Data.JSDate (JSDate)
import Data.JSDate as JSDate
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Elmish (ReactElement)
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks

view :: ReactElement
view = Hooks.component Hooks.do
  exerciseHistory' /\ setExerciseHistory <- Hooks.useState Nothing
  modal /\ setModal <- Hooks.useState Nothing

  Hooks.useEffect do
    sessions <- Api.sessions "Ms1WqYNb" -- TODO: Don’t hardcode id
    for_ sessions \s ->
      liftEffect $ setExerciseHistory $ Just $ exerciseHistory s

  Hooks.pure $ H.fragment
    [ H.div "row mt-3" $
        case exerciseHistory' of
          Just history -> H.fragment $
            history # (Map.toUnfoldable :: _ -> Array _) <#> \(kind /\ setHistories) ->
              H.div "col-12 col-md-6 col-lg-4" $
                H.div "card lift mb-3" $
                  H.div "card-body"
                  [ H.h6_ "card-title text-uppercase text-secondary"
                      { onClick: setModal $ Just kind, role: "button" }
                      kind
                  , responsiveContainer { height: pixels 300.0 } $
                      lineChart { data: setHistories } $
                        maximum (length <<< _.weights <$> setHistories) # fromMaybe 0 # (_ - 1) # range 0 <#> \index ->
                          line
                            { dataKey: dataKeyFunction (_.weights >>> (_ !! index))
                            , type: monotone
                            , stroke: color index
                            }
                  ]
          Nothing ->
            H.div "position-absolute top-0 bottom-0 start-0 end-0 d-flex justify-content-center align-items-center" $
              H.div "spinner-grow spinner-grow-xl text-white display-4"
              [ H.text "❤️"
              , H.span "sr-only" "Loading…"
              ]
    , fromMaybe H.empty do
        kind <- modal
        history <- exerciseHistory'
        setHistories <- Map.lookup kind history
        pure $ H.fragment
          [ H.div "modal fade show d-block" $
              H.div "modal-dialog modal-fullscreen" $
                H.div "modal-content"
                [ H.div "modal-header"
                  [ H.h2 "modal-title" kind
                  , H.button_ "btn-close" { onClick: setModal Nothing } H.empty
                  ]
                , H.div "modal-body" $
                    responsiveContainer {} $
                      lineChart { data: setHistories }
                      [ H.fragment $
                          maximum (length <<< _.weights <$> setHistories) # fromMaybe 0 # (_ - 1) # range 0 # mapWithIndex \index _ ->
                            line
                              { dataKey: dataKeyFunction (_.weights >>> (_ !! index))
                              , name: "Set " <> show (index + 1) <> " Weight"
                              , stroke: color index
                              , strokeWidth: 2.0
                              }
                      , xAxis
                          { dataKey: dataKeyString "date"
                          , tickFormatter: tickFormatter JSDate.toDateString
                          }
                      , yAxis {}
                      , cartesianGrid { strokeDasharray: "3 3" }
                      , tooltip {}
                      ]
                ]
          , H.div "modal-backdrop fade show" H.empty
          ]
    ]

exerciseHistory :: Array Api.Session -> Map String (Array { date :: JSDate, weights :: Array Number })
exerciseHistory = foldl insertExerciseHistories Map.empty
  where
    insertExerciseHistories history session =
      foldl (insertExerciseHistory session) history session.exercises

    insertExerciseHistory session history exercise =
      Map.insertWith (<>) exercise.kind [{ date: session.date, weights: _.weight <$> exercise.sets }] history

color :: Int -> String
color index = colors !! (index `mod` length colors) # fromMaybe default
  where
    colors =
      [ default
      , "#EA4235"
      , "#FBBC05"
      , "#33A854"
      , "#FF6D02"
      , "#46BDC6"
      , "#7BAAF7"
      , "#F07B72"
      , "#FCD050"
      ]

    default = "#4385F4"
