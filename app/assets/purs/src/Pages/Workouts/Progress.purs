module Pages.Workouts.Progress
  ( view
  )
  where

import Prelude

import Api as Api
import Components.Recharts.CartesianGrid (cartesianGrid)
import Components.Recharts.Line (line, monotone)
import Components.Recharts.LineChart (lineChart)
import Components.Recharts.ResponsiveContainer (percent, pixels, responsiveContainer)
import Components.Recharts.Tooltip (tooltip)
import Components.Recharts.Types.DataKey (dataKeyFunction, dataKeyString)
import Components.Recharts.XAxis (tickFormatter, xAxis)
import Components.Recharts.YAxis (yAxis)
import Data.Array (foldl, length, mapWithIndex, range, (!!))
import Data.Array as Array
import Data.Foldable (maximum, sum)
import Data.Int as Int
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
import Types.Workouts.Session (Session)
import Utils.Assets (assetPath)
import Utils.Html (htmlIf, (&.>))

type Props =
  { userId :: String
  }

data ChartType
  = Weight
  | Volume
derive instance Eq ChartType

view :: Props -> ReactElement
view props = Hooks.component Hooks.do
  sessions /\ setSessions <- Hooks.useState Nothing
  exerciseHistory' /\ setExerciseHistory <- Hooks.useState Nothing
  modal /\ setModal <- Hooks.useState Nothing
  muscleGroup /\ setMuscleGroup <- Hooks.useState Nothing

  Hooks.useEffect do
    s <- Api.sessions props.userId
    liftEffect do
      setSessions s
      setExerciseHistory (exerciseHistory <$> s)

  let
    exerciseKindsForMuscleGroup mg =
      sessions
        # fromMaybe []
        # Array.filter (eq mg <<< _.muscleGroup.id)
        >>= _.exercises
        <#> _.kind
    filterByMuscleGroup = setExerciseHistory <<< case _ of
      Just mg -> Map.filterKeys (_ `Array.elem` exerciseKindsForMuscleGroup mg) <<< exerciseHistory <$> sessions
      Nothing -> exerciseHistory <$> sessions

  Hooks.useEffect' muscleGroup (liftEffect <<< filterByMuscleGroup)

  Hooks.pure $
    H.div "container-fluid mt-3"
    [ H.div "row" $
        case exerciseHistory' of
          Just history
            | Map.isEmpty history ->
              H.div "col text-center"
              [ H.h3 "" "Looks like there’s nothing here, yet"
              , H.p "text-muted" "Track your first workout to get started"
              , H.div_ "mx-auto"
                  { style: H.css
                      { background: "url(" <> assetPath "/empty-gym.png" <> ")"
                      , backgroundSize: "cover"
                      , height: 400
                      , maxHeight: "100%"
                      , width: 400
                      , maxWidth: "100%"
                      , boxShadow: "inset 0 0 150px white"
                      }
                  }
                  H.empty
              ]
            | otherwise -> H.fragment
              [ sessions &.> \s ->
                  s <#> _.muscleGroup # Array.nub # \muscleGroups ->
                    htmlIf (Array.length muscleGroups > 1) $
                      H.div "col-12"
                      [ H.strong "d-none d-md-inline me-2" "Filter by:"
                      , H.div "d-inline-block" $
                          H.ul "nav nav-pills mb-3" $
                            muscleGroups <#> \{ id, name } ->
                              H.li "nav-item" $
                                H.a_ ("nav-link" <> if muscleGroup == Just id then " active" else "")
                                  { onClick: setMuscleGroup
                                      if muscleGroup == Just id then
                                        Nothing
                                      else
                                        Just id
                                  , href: "#"
                                  }
                                  name
                      ]
              , H.fragment $
                  history # (Map.toUnfoldable :: _ -> Array _) <#> \(kind /\ setHistories) ->
                    H.div "col-12 col-md-6 col-lg-4" $
                      H.div "card lift mb-3" $
                        H.div "card-body"
                        [ H.h6_ "card-title text-uppercase text-secondary"
                            { onClick: setModal $ Just { exerciseKind: kind, chartType: Weight }, role: "button" }
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
              ]
          Nothing ->
            H.div "position-absolute top-0 bottom-0 start-0 end-0 d-flex justify-content-center align-items-center" $
              H.div "spinner-grow spinner-grow-xl text-white display-4"
              [ H.text "❤️"
              , H.span "sr-only" "Loading…"
              ]
    , fromMaybe H.empty do
        { exerciseKind, chartType } <- modal
        history <- exerciseHistory'
        setHistories <- Map.lookup exerciseKind history
        pure $ H.fragment
          [ H.div "modal fade show d-block" $
              H.div "modal-dialog modal-fullscreen" $
                H.div "modal-content"
                [ H.div "modal-header"
                  [ H.h2 "modal-title" exerciseKind
                  , H.button_ "btn-close" { onClick: setModal Nothing } H.empty
                  ]
                , H.div "modal-body"
                  [ H.div "d-flex justify-content-center mt-n2 mb-2"
                    [ H.button_ ("btn btn-sm me-1 btn-" <> if chartType == Weight then "primary" else "outline-primary")
                        { onClick: setModal $ Just { exerciseKind, chartType: Weight } }
                        "Weight"
                    , H.button_ ("btn btn-sm ms-1 btn-" <> if chartType == Volume then "primary" else "outline-primary")
                        { onClick: setModal $ Just { exerciseKind, chartType: Volume } }
                        "Volume"
                    ]
                  , responsiveContainer { height: percent 90.0 } $
                      lineChart { data: setHistories }
                      [ case chartType of
                          Weight -> H.fragment $
                            maximum (length <<< _.weights <$> setHistories) # fromMaybe 0 # (_ - 1) # range 0 # mapWithIndex \index _ ->
                              line
                                { dataKey: dataKeyFunction (_.weights >>> (_ !! index))
                                , name: "Set " <> show (index + 1) <> " Weight"
                                , stroke: color index
                                , strokeWidth: 2.0
                                }
                          Volume ->
                            line
                              { dataKey: dataKeyString "volume"
                              , name: "Volume"
                              , stroke: defaultColor
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
                ]
          , H.div "modal-backdrop fade show" H.empty
          ]
    ]

exerciseHistory :: Array Session -> Map String (Array { date :: JSDate, weights :: Array Number, volume :: Number })
exerciseHistory = foldl insertExerciseHistories Map.empty
  where
    insertExerciseHistories history session =
      foldl (insertExerciseHistory session) history session.exercises

    insertExerciseHistory session history exercise =
      Map.insertWith (<>)
        exercise.kind
        [ { date: session.date
          , weights: _.weight <$> exercise.sets
          , volume: sum $ volume <$> exercise.sets
          }
        ]
        history

    volume { weight, reps } = weight * Int.toNumber reps

color :: Int -> String
color index = colors !! (index `mod` length colors) # fromMaybe defaultColor
  where
    colors =
      [ defaultColor
      , "#EA4235"
      , "#FBBC05"
      , "#33A854"
      , "#FF6D02"
      , "#46BDC6"
      , "#7BAAF7"
      , "#F07B72"
      , "#FCD050"
      ]

defaultColor :: String
defaultColor = "#4385F4"
