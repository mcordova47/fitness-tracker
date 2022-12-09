module Pages.Workouts.Progress
  ( view
  )
  where

import Prelude

import Api as Api
import Components.Dropdown (dropdown)
import Components.Recharts.ResponsiveContainer (percent, pixels, responsiveContainer)
import Data.Array (foldl)
import Data.Array as Array
import Data.Foldable (sum)
import Data.Int as Int
import Data.JSDate (JSDate)
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Elmish (ReactElement)
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks
import Pages.Workouts.Progress.Chart (ChartType(..))
import Pages.Workouts.Progress.Chart as Chart
import Types.Workouts.Session (Session)
import Utils.Assets (assetPath)
import Utils.Html (htmlIf, (&.>))

type Props =
  { userId :: String
  }

view :: Props -> ReactElement
view props = Hooks.component Hooks.do
  sessions /\ setSessions <- Hooks.useState Nothing
  exerciseHistory' /\ setExerciseHistory <- Hooks.useState Nothing
  modal /\ setModal <- Hooks.useState Nothing
  chartType /\ setChartType <- Hooks.useState Weight
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
    H.div "container-fluid mt-2"
    [ H.div "row" $
        case exerciseHistory' of
          Just history
            | Map.isEmpty history ->
              H.div "col text-center mt-2"
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
                      H.div "col-12 d-flex justify-content-between pb-2" $
                      [ dropdown "d-inline-block"
                          { toggleClass: "btn btn-light"
                          , toggleContent:
                              H.span "fa-solid fa-sliders" $
                                muscleGroup &.> \_ ->
                                  H.span_ "position-absolute top-0 start-100 translate-middle badge rounded-pill bg-primary"
                                    { style: H.css { fontSize: "0.5rem" }
                                    } $
                                    [ H.text "1"
                                    , H.span "visually-hidden" " applied filters"
                                    ]
                          } $
                          H.div "px-3 pt-1 pb-2"
                          [ H.div "text-muted" "Muscle groups"
                          , H.div "btn-group-vertical btn-group-sm w-100 mt-2" $
                              muscleGroups <#> \{ id, name } ->
                                H.button_ ("btn w-100 btn-" <> if muscleGroup == Just id then "primary" else "outline-primary")
                                  { onClick: setMuscleGroup
                                      if muscleGroup == Just id then
                                        Nothing
                                      else
                                        Just id
                                  }
                                  name
                          ]
                      , H.div "btn-group"
                        [ H.button_ ("btn btn-" <> if chartType == Weight then "primary" else "outline-primary")
                            { onClick: setChartType Weight }
                            "Weight"
                        , H.button_ ("btn btn-" <> if chartType == Volume then "primary" else "outline-primary")
                            { onClick: setChartType Volume }
                            "Volume"
                        ]
                      ]
              , H.fragment $
                  history # (Map.toUnfoldable :: _ -> Array _) <#> \(kind /\ setHistories) ->
                    H.div "col-12 col-md-6 col-lg-4" $
                      H.div "card lift mb-3" $
                        H.div "card-body"
                        [ H.h6_ "card-title text-uppercase text-secondary"
                            { onClick: setModal $ Just kind
                            , role: "button"
                            }
                            kind
                        , responsiveContainer { height: pixels 300.0 } $
                            Chart.view
                              { chartType
                              , data': setHistories
                              , minimal: true
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
        exerciseKind <- modal
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
                  [ H.div "mt-n2 mb-2 text-center" $
                      H.div "btn-group btn-group-sm"
                      [ H.button_ ("btn btn-" <> if chartType == Weight then "primary" else "outline-primary")
                          { onClick: setChartType Weight }
                          "Weight"
                      , H.button_ ("btn btn-" <> if chartType == Volume then "primary" else "outline-primary")
                          { onClick: setChartType Volume }
                          "Volume"
                      ]
                  , responsiveContainer { height: percent 90.0 } $
                      Chart.view
                        { chartType
                        , data': setHistories
                        , minimal: false
                        }
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
