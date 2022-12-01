module Pages.WorkOut
  ( view
  )
  where

import Prelude

import Api as Api
import Components.ReactSelect.CreatableSelect (creatableSelect)
import Data.Array (find, null)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Nullable as Nullable
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Elmish (EffectFn1, ReactElement, mkEffectFn1)
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks
import Utils.Html ((?>))

type Props =
  { exerciseKinds :: Array ExerciseKind
  , muscleGroups :: Array MuscleGroup
  , userId :: String
  }

data View
  = Empty
  | ChooseExercise Api.Session
  | ChooseMuscleGroup
  | AddExercises Api.Session
  | AddSets Api.Session ExerciseKind

type ExerciseKind = { kind :: String }

type MuscleGroup = { name :: String }

view :: Props -> ReactElement
view { exerciseKinds, muscleGroups, userId } = Hooks.component Hooks.do
  view' /\ setView <- Hooks.useState Empty

  Hooks.useEffect do
    Api.todaysSession userId >>= case _ of
      Just session ->
        liftEffect $ setView $ AddExercises session
      Nothing ->
        liftEffect $ setView ChooseMuscleGroup

  Hooks.pure $
    case view' of
      Empty -> H.empty
      ChooseExercise session ->
        H.fragment
        [ addExercisesView session setView
        , modal
            { content:
                creatableSelect
                  { onChange: createExerciseKind session setView _.value
                  , onCreateOption: createExerciseKind session setView identity
                  , options: exerciseKinds <#> \{ kind } -> { label: kind, value: kind }
                  , placeholder: "Select an exercise"
                  , defaultValue: Nullable.null
                  }
            , title: "What’s up next?"
            }
        ]
      ChooseMuscleGroup ->
        modal
          { content:
              creatableSelect
                { onChange: createSession setView _.value
                , onCreateOption: createSession setView identity
                , options: muscleGroups <#> \{ name } -> { label: name, value: name }
                , placeholder: "Select muscle group"
                , defaultValue: Nullable.null
                }
          , title: "Which muscle group are you working out today?"
          }
      AddExercises session ->
        addExercisesView session setView
      AddSets session exerciseKind ->
        addSetsView session exerciseKind setView
  where
    addExercisesView session setView =
      H.div "container pt-4"
      [ H.h3 "" $ session.muscleGroup.name <> " day"
      , null session.exercises ?>
          H.div "text-muted mb-1" "Add some exercises below to get started"
      , H.div "list-group"
        [ H.fragment $ session.exercises <#> \exercise ->
            H.a_ "list-group-item"
              { href: "#"
              , onClick: setView $ AddSets session { kind: exercise.kind }
              }
              exercise.kind
        , H.a_ "list-group-item"
            { href: "#"
            , onClick: setView $ ChooseExercise session
            }
            "+ Add an exercise"
        ]
      ]

    addSetsView session { kind } setView =
      H.div "container pt-4"
      [ H.div ""
        [ H.a_ ""
            { href: "#"
            , onClick: setView $ AddExercises session
            } $
            H.h3 "d-inline-block" $ session.muscleGroup.name <> " day"
        , H.h5 "d-inline-block ms-2" $ "> " <> kind
        ]
      , fromMaybe H.empty do
          exercise <- session.exercises # find (eq kind <<< _.kind)
          pure $ H.fragment
            [ null exercise.sets ?>
                H.div "text-muted mb-1" "Add a new set below to get started"
            , H.table "table table-hover"
              [ H.thead "" $
                  H.tr ""
                  [ H.th_ "" { scope: "col" } "Weight"
                  , H.th_ "" { scope: "col" } "Reps"
                  ]
              , H.tbody ""
                [ H.fragment $ exercise.sets <#> \set ->
                    H.tr ""
                    [ H.th_ "" { scope: "row" } $ show set.weight
                    , H.td "" $ show set.reps
                    ]
                , H.tr ""
                  [ H.th_ "" { scope: "row" } "+ Add a set"
                  , H.td "" H.empty
                  ]
                ]
              ]
            ]
      ]

    createSession :: ∀ opt. (View -> Effect Unit) -> (opt -> String) -> EffectFn1 opt Unit
    createSession setView toValue = mkEffectFn1 \mg -> launchAff_ do
      mSession <- Api.saveSession { muscleGroup: toValue mg, userId }
      for_ mSession \session ->
        liftEffect $ setView $ AddExercises session

    createExerciseKind :: ∀ opt. Api.Session -> (View -> Effect Unit) -> (opt -> String) -> EffectFn1 opt Unit
    createExerciseKind session setView toValue = mkEffectFn1 \e -> launchAff_ do
      let kind = toValue e
      Api.createExerciseKind { kind, userId }
      liftEffect $ setView $ AddSets
        session { exercises = session.exercises <> [{ kind, sets: [] }] }
        { kind }

    modal { content, title } =
      H.fragment
      [ H.div "modal fade show d-block" $
          H.div "modal-dialog modal-dialog-centered modal-lg" $
            H.div "modal-content"
            [ H.div "modal-header" $
                H.h4 "modal-title" title
            , H.div "modal-body" content
            ]
      , H.div "modal-backdrop fade show" H.empty
      ]
