module Pages.WorkOut
  ( view
  )
  where

import Prelude

import Api (Session)
import Api as Api
import Components.ReactSelect.CreatableSelect (creatableSelect)
import Data.Array (find, null)
import Data.Array as Array
import Data.Foldable (for_)
import Data.Int as Int
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Data.Nullable as Nullable
import Data.Number as Number
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Elmish (EffectFn1, ReactElement, mkEffectFn1, (<?|))
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks
import Utils.Array (updateWhere)
import Utils.Events (eventTargetValue)
import Utils.Html ((?>))

type Props =
  { exerciseKinds :: Array ExerciseKind
  , muscleGroups :: Array MuscleGroup
  , userId :: String
  }

data View
  = Loading
  | ChooseMuscleGroup { modal :: Boolean }
  | AddExercises AddExercisesState
  | AddSets AddSetsState

type ExerciseKind = { kind :: String }

type MuscleGroup = { name :: String }

type AddExercisesState =
  { modal :: Boolean
  , session :: Session
  }

type AddSetsState =
  { exerciseKind :: ExerciseKind
  , modal :: Maybe SetModal
  -- ^ Index of the Set which is opened
  , session :: Session
  }

data SetModal
  = ExistingSet Int
  | NewSet
derive instance Eq SetModal

view :: Props -> ReactElement
view { exerciseKinds, muscleGroups, userId } = Hooks.component Hooks.do
  view' /\ setView <- Hooks.useState Loading

  Hooks.useEffect do
    Api.todaysSession userId >>= case _ of
      Just session ->
        liftEffect $ setView $ AddExercises { session, modal: false }
      Nothing ->
        liftEffect $ setView $ ChooseMuscleGroup { modal: true }

  Hooks.pure $
    case view' of
      Loading ->
        H.empty
      ChooseMuscleGroup { modal } ->
        H.div "container pt-4"
        [ H.h3 "" "New session"
        , H.button_ "btn btn-link p-0"
            { onClick: setView $ ChooseMuscleGroup { modal: true } }
            "Choose a muscle group to begin"
        , modal ?>
            modal'
              { content:
                  creatableSelect
                    { onChange: createSession setView _.value
                    , onCreateOption: createSession setView identity
                    , options: muscleGroups <#> \{ name } -> { label: name, value: name }
                    , placeholder: "Select muscle group"
                    , defaultValue: Nullable.null
                    }
              , onDismiss: setView $ ChooseMuscleGroup { modal: false }
              , title: "Which muscle group are you working out today?"
              }
        ]
      AddExercises { session, modal } ->
        H.div "container pt-4"
        [ H.h3 "" $ session.muscleGroup.name <> " day"
        , null session.exercises ?>
            H.div "text-muted mb-1" "Add some exercises below to get started"
        , H.div "list-group"
          [ H.fragment $ session.exercises <#> \exercise ->
              H.a_ "list-group-item"
                { href: "#"
                , onClick: setView $ AddSets
                    { exerciseKind: { kind: exercise.kind }
                    , modal: Nothing
                    , session
                    }
                }
                exercise.kind
          , H.a_ "list-group-item"
              { href: "#"
              , onClick: setView $ AddExercises { session, modal: true }
              }
              "+ Add an exercise"
          ]
        , modal ?>
            modal'
              { content:
                  creatableSelect
                    { onChange: createExercise session setView _.value
                    , onCreateOption: createExercise session setView identity
                    , options: exerciseKinds <#> \{ kind } -> { label: kind, value: kind }
                    , placeholder: "Select an exercise"
                    , defaultValue: Nullable.null
                    }
              , onDismiss: setView $ AddExercises { session, modal: false }
              , title: "What’s up next?"
              }
        ]
      AddSets s@{ exerciseKind, session } ->
        H.div "container pt-4"
        [ H.div ""
          [ H.a_ ""
              { href: "#"
              , onClick: setView $ AddExercises { session, modal: false }
              } $
              H.h3 "d-inline-block" $ session.muscleGroup.name <> " day"
          , H.h5 "d-inline-block ms-2" $ "> " <> exerciseKind.kind
          ]
        , fromMaybe H.empty do
            exercise <- session.exercises # find (eq exerciseKind.kind <<< _.kind)
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
                      H.tr_ ""
                      { onClick: setView $ AddSets { exerciseKind, modal: Just $ ExistingSet set.id, session }
                      }
                      [ H.th_ "" { scope: "row" } $ show set.weight
                      , H.td "" $ show set.reps
                      ]
                  , H.tr_ "cursor-pointer"
                    { onClick: setView $ AddSets { exerciseKind, modal: Just NewSet, session } }
                    [ H.th_ "" { scope: "row" } "+ Add a set"
                    , H.td "" H.empty
                    ]
                  ]
                ]
              , addSetModal s exercise setView
              ]
        ]
  where
    createSession :: ∀ opt. (View -> Effect Unit) -> (opt -> String) -> EffectFn1 opt Unit
    createSession setView toValue = mkEffectFn1 \mg -> launchAff_ do
      mSession <- Api.createSession { muscleGroup: toValue mg, userId }
      for_ mSession \session ->
        liftEffect $ setView $ AddExercises { session, modal: false }

    createExercise :: ∀ opt. Session -> (View -> Effect Unit) -> (opt -> String) -> EffectFn1 opt Unit
    createExercise session setView toValue = mkEffectFn1 \e -> launchAff_ do
      let kind = toValue e
      mExercise <- Api.createExercise { kind, userId }
      for_ mExercise \exercise ->
        liftEffect $ setView $ AddSets
          { exerciseKind: { kind }
          , modal: Nothing
          , session: session { exercises = session.exercises <> [exercise] }
          }

    addSetModal { exerciseKind, modal, session } exercise setView =
      fromMaybe H.empty do
        editSetModal <- modal
        pure $ Hooks.component Hooks.do
          let mSet = exercise.sets # Array.find (eq editSetModal <<< ExistingSet <<< _.id)
          weight /\ setWeight <- Hooks.useState $ maybe "" (show <<< _.weight) mSet
          reps /\ setReps <- Hooks.useState $ maybe "" (show <<< _.reps) mSet
          Hooks.pure $ modal'
            { content:
                H.fragment
                [ H.div "row align-items-center"
                  [ H.div "col-3" $
                      H.label_ "form-label mb-0"
                        { htmlFor: "weight-input" }
                        "Weight"
                  , H.div "col-9" $
                      H.input_ "form-control"
                        { id: "weight-input"
                        , onChange: setWeight <?| eventTargetValue
                        , type: "number"
                        , value: weight
                        }
                  ]
                , H.div "row align-items-center mt-3"
                  [ H.div "col-3" $
                      H.label_ "form-label mb-0"
                        { htmlFor: "reps-input" }
                        "Reps"
                  , H.div "col-9" $
                      H.input_ "form-control"
                        { id: "reps-input"
                        , onChange: setReps <?| eventTargetValue
                        , type: "number"
                        , value: reps
                        }
                  ]
                , H.button_ "btn btn-primary px-4 mt-3"
                    { onClick: fromMaybe (pure unit) do
                        weight' <- Number.fromString weight
                        reps' <- Int.fromString reps
                        pure $ launchAff_ do
                          mExercise <-
                            case editSetModal of
                              NewSet ->
                                Api.addSet { exerciseId: exercise.id, reps: reps', userId, weight: weight' }
                              ExistingSet id ->
                                Api.updateSet { id, reps: reps', userId, weight: weight' } -- TODO: Update exiting Set
                          for_ mExercise \exercise' ->
                            liftEffect $ setView $ AddSets
                              { exerciseKind
                              , modal: Nothing
                              , session: session
                                  { exercises = session.exercises #
                                      updateWhere (eq exerciseKind.kind <<< _.kind) exercise'
                                  }
                              }
                    }
                    "Save"
                ]
            , onDismiss: setView $ AddSets { exerciseKind, modal: Nothing, session }
            , title: "How’d it go?"
            }

    modal' { content, onDismiss, title } =
      H.fragment
      [ H.div "modal fade show d-block" $
          H.div "modal-dialog modal-dialog-centered modal-lg" $
            H.div "modal-content"
            [ H.div "modal-header"
              [ H.h4 "modal-title" title
              , H.button_ "btn-close" { onClick: onDismiss } H.empty
              ]
            , H.div "modal-body" content
            ]
      , H.div "modal-backdrop fade show" H.empty
      ]
