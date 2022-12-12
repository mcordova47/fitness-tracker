module Pages.Workouts.Progress
  ( view
  )
  where

import Prelude

import Api as Api
import Components.ButtonGroup as ButtonGroup
import Components.Recharts.ResponsiveContainer (pixels, responsiveContainer)
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
import Pages.Workouts.Progress.Filters as Filters
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
    H.div "mt-3"
    [ H.div "row" $
        case exerciseHistory' of
          Just history
            | Map.isEmpty history ->
              H.div "text-center mt-3"
              [ H.h3 "text-2xl mb-2" "Looks like there’s nothing here, yet"
              , H.p "text-slate-500 dark:text-slate-200" "Track your first workout to get started"
              , H.div_ "mx-auto mt-3"
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
                      H.div "flex justify-between pb-3" $
                      [ Filters.view
                          { muscleGroup
                          , muscleGroups
                          , setMuscleGroup
                          }
                      , ButtonGroup.view
                          { onClick: setChartType
                          , options:
                              [ { label: "Weight", value: Weight }
                              , { label: "Volume", value: Volume }
                              ]
                          , value: Just chartType
                          }
                      ]
              , H.div "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4" $
                  history # (Map.toUnfoldable :: _ -> Array _) <#> \(kind /\ setHistories) ->
                    H.div "border border-slate-200 dark:border-slate-700 dark:bg-slate-700 rounded-lg" $
                    [ H.h6_ "text-slate-500 text-sm border-b border-slate-200 dark:text-white dark:bg-slate-800 dark:border-none p-4 uppercase rounded-t-lg"
                        { onClick: setModal $ Just kind
                        , role: "button"
                        }
                        kind
                    , H.div "p-4" $
                        responsiveContainer { height: pixels 300.0 } $
                          Chart.view
                            { chartType
                            , keyPrefix: "preview"
                            , data': setHistories
                            , minimal: true
                            }
                    ]
              ]
          Nothing ->
            H.div "absolute top-0 bottom-0 left-0 right-0 flex justify-center items-center" $
              H.div "animate-ping text-white text-4xl"
              [ H.text "❤️"
              , H.span "sr-only" "Loading…"
              ]
    , fromMaybe H.empty do
        exerciseKind <- modal
        history <- exerciseHistory'
        setHistories <- Map.lookup exerciseKind history
        pure $
          H.div "fixed top-0 left-0 right-0 bottom-0 bg-white dark:bg-slate-700 flex flex-col" $
          [ H.div "flex w-full justify-between p-4 dark:bg-slate-800 border-b border-slate-200 dark:border-none"
            [ H.h2 "text-3xl" exerciseKind
            , H.button_ "text-slate-500 dark:text-slate-300 dark:hover:text-slate-100 text-3xl" { onClick: setModal Nothing } $
                H.span "fa fa-xmark" H.empty
            ]
          , H.div "grow flex flex-col"
            [ H.div "flex items-center py-2" $
                H.div "inline-block mx-auto" $
                  ButtonGroup.view
                    { onClick: setChartType
                    , options:
                        [ { label: "Weight", value: Weight }
                        , { label: "Volume", value: Volume }
                        ]
                    , value: Just chartType
                    }
            , H.div "grow" $
                responsiveContainer {} $
                  Chart.view
                    { chartType
                    , keyPrefix: "detail"
                    , data': setHistories
                    , minimal: false
                    }
            ]
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
