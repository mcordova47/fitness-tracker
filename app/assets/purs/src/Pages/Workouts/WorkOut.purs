module Pages.Workouts.WorkOut
  ( view
  )
  where

import Prelude

import Api as Api
import Components.ReactSelect.CreatableSelect (creatableSelect)
import Data.Array (find, null, (!!))
import Data.Array as Array
import Data.Foldable (for_, traverse_)
import Data.Int as Int
import Data.Maybe (Maybe(..), fromMaybe, isNothing, maybe)
import Data.Nullable as Nullable
import Data.Number as Number
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Elmish (EffectFn1, ReactElement, mkEffectFn1, (<?|))
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks
import Types.Workouts.ExerciseKind (ExerciseKind)
import Types.Workouts.MuscleGroup (MuscleGroup)
import Types.Workouts.Session (Session)
import Unsafe.Coerce (unsafeCoerce)
import Utils.Array (updateWhere)
import Utils.Events (eventTargetValue)
import Utils.Html (htmlIf, (&.>), (&>))
import Utils.String (Plural(..), Singular(..), pluralize)
import Web.Event.Event (stopPropagation)

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

type AddExercisesState =
  { modal :: Boolean
  , session :: Session
  }

type AddSetsState =
  { exerciseKind :: ExerciseKind
  , modal :: Maybe SetModal
  , session :: Session
  }

data SetModal
  = ExistingSet Int
  | NewSet
derive instance Eq SetModal

view :: Props -> ReactElement
view { exerciseKinds, muscleGroups, userId } = Hooks.component Hooks.do
  view' /\ setView <- Hooks.useState Loading
  lastSession /\ setLastSession <- Hooks.useState Nothing

  Hooks.useEffect do
    Api.todaysSession userId >>= case _ of
      Just session -> do
        liftEffect $ setView $ AddExercises { session, modal: false }
        fetchLastSession session setLastSession
      Nothing ->
        liftEffect $ setView $ ChooseMuscleGroup { modal: true }

  Hooks.pure $
    H.div "container py-4" case view' of
      Loading ->
        H.empty
      ChooseMuscleGroup { modal } ->
        H.fragment
        [ H.h3 "" "New session"
        , H.p "text-muted"
          [ H.button_ "btn btn-link p-0"
              { onClick: setView $ ChooseMuscleGroup { modal: true } }
              "Choose a muscle group"
          , H.text " to begin."
          ]
        , modal &>
            modal'
              { content:
                  creatableSelect
                    { onChange: createSession setView setLastSession _.value
                    , onCreateOption: createSession setView setLastSession identity
                    , options: muscleGroups <#> \{ name } -> { label: name, value: name }
                    , placeholder: "Select muscle group"
                    , defaultValue: Nullable.null
                    }
              , onDismiss: setView $ ChooseMuscleGroup { modal: false }
              , title: "Which muscle group are you working out today?"
              }
        ]
      AddExercises { session, modal } ->
        H.fragment
        [ H.h3 "" $ session.muscleGroup.name <> " day"
        , null session.exercises &>
            H.div "text-muted mb-1" "Add some exercises below to get started"
        , H.div "list-group"
          [ H.fragment $ session.exercises # Array.mapWithIndex \index exercise ->
              H.a_ ("list-group-item d-flex justify-content-between align-items-center group" <> if null exercise.sets then "" else " text-success")
                { href: "#"
                , onClick: setView $ AddSets
                    { exerciseKind: { kind: exercise.kind }
                    , modal: Nothing
                    , session
                    }
                }
                [ H.div ""
                  [ not null exercise.sets &>
                      H.text "✓ "
                  , if null exercise.sets then
                      H.text exercise.kind
                    else
                      H.del "" exercise.kind
                  , not null exercise.sets &>
                      H.fragment
                      [ H.text " · "
                      , H.text $ show $ Array.length exercise.sets
                      , H.text " "
                      , H.text $ pluralize (Array.length exercise.sets) (Singular "set") (Plural "sets")
                      ]
                  ]
                , H.div "d-md-none group-hover:d-block" $
                    H.button_ "btn-sm btn-close p-0"
                      { onClick: unsafeCoerce $ mkEffectFn1 \e -> do
                          stopPropagation e
                          launchAff_ $
                            Api.deleteExercise { userId, exerciseId: exercise.id }
                          setView $ AddExercises
                            { session: session
                                { exercises =
                                    session.exercises
                                      # Array.deleteAt index
                                      # fromMaybe session.exercises
                                }
                            , modal: false
                            }
                      }
                      H.empty
                ]
          , H.a_ "list-group-item"
              { href: "#"
              , onClick: setView $ AddExercises { session, modal: true }
              }
              "+ Add an exercise"
          ]
        , lastSession &.> \{ id, exercises } ->
            H.fragment
            [ H.h5 "mt-5"
              [ H.text "Here’s what you did last time "
              , null session.exercises &>
                  H.button_ "btn btn-link p-0"
                    { onClick: launchAff_ do
                        Api.copySessionToToday { sessionId: id, userId } >>= traverse_ \session' ->
                          liftEffect $ setView $ AddExercises { session: session', modal: false }
                    }
                    "(Copy to today’s session)"
              ]
            , H.ul "list-group" $
                exercises <#> \exercise ->
                  H.li "list-group-item"
                  [ H.text exercise.kind
                  , H.span "text-muted"
                    [ H.text " · "
                    , H.text $ show $ Array.length exercise.sets
                    , H.text " "
                    , H.text $ pluralize (Array.length exercise.sets) (Singular "set") (Plural "sets")
                    ]
                  ]
            ]
        , modal &>
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
      AddSets s ->
        addSetsView s setView
  where
    fetchLastSession session setLastSession =
      Api.lastSession userId session.muscleGroup
        >>= liftEffect <<< setLastSession

    fetchLastExercise kind setLastExercise =
      Api.lastExercise userId kind
        >>= liftEffect <<< setLastExercise

    fetchMaxSet kind setMaxSet =
      Api.maxSet userId kind
        >>= liftEffect <<< setMaxSet

    createSession :: ∀ opt. (View -> Effect Unit) -> (Maybe Session -> Effect Unit) -> (opt -> String) -> EffectFn1 opt Unit
    createSession setView setLastSession toValue = mkEffectFn1 \mg -> launchAff_ do
      mSession <- Api.createSession { muscleGroup: toValue mg, userId }
      for_ mSession \session -> do
        liftEffect $ setView $ AddExercises { session, modal: false }
        fetchLastSession session setLastSession

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

    addSetsView s@{ exerciseKind, session } setView = Hooks.component Hooks.do
      lastExercise /\ setLastExercise <- Hooks.useState Nothing
      maxSet /\ setMaxSet <- Hooks.useState Nothing

      Hooks.useEffect do
        fetchLastExercise exerciseKind.kind setLastExercise
        fetchMaxSet exerciseKind.kind setMaxSet

      Hooks.pure $
        H.fragment
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
              [ null exercise.sets &>
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
              , H.div "row mt-5"
                [ lastExercise &.> \ex ->
                    H.div "col-12 col-md-6 col-lg-8" $
                      H.div "card mb-3" $
                        H.div "card-body"
                        [ H.h5 "" "Here’s what you did last time"
                        , H.table "table"
                          [ H.thead "" $
                              H.tr ""
                              [ H.th_ "" { scope: "col" } "Weight"
                              , H.th_ "" { scope: "col" } "Reps"
                              ]
                          , H.tbody "" $
                              ex.sets <#> \set ->
                                H.tr ""
                                [ H.th_ "" { scope: "row" } $ show set.weight
                                , H.td "" $ show set.reps
                                ]
                          ]
                        ]
                , maxSet &.> \{ weight, reps } ->
                    H.div "col-12 col-md-6 col-lg-4" $
                      H.div "card mb-3" $
                        H.div "card-body"
                        [ H.h5 "" "All-time max"
                        , H.div "row mt-3"
                          [ H.div "col-6"
                            [ H.h6 "text-muted" "Weight"
                            , H.div "display-4" $ show weight
                            ]
                          , H.div "col-6"
                            [ H.h6 "text-muted" "Reps"
                            , H.div "display-4" $ show reps
                            ]
                          ]
                        ]
                ]
              , addSetModal s exercise setView
              ]
        ]

    addSetModal { exerciseKind, modal, session } exercise setView =
      fromMaybe H.empty do
        editSetModal <- modal
        pure $ Hooks.component Hooks.do
          let
            setIndex = exercise.sets # Array.findIndex (eq editSetModal <<< ExistingSet <<< _.id) # fromMaybe (Array.length exercise.sets)
            mSet = exercise.sets !! setIndex
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
                , H.button_ "btn btn-primary px-4 mt-3 me-3"
                    { onClick: fromMaybe (pure unit) do
                        weight' <- Number.fromString weight
                        reps' <- Int.fromString reps
                        pure $ launchAff_ do
                          mExercise <-
                            case editSetModal of
                              NewSet ->
                                Api.addSet { exerciseId: exercise.id, reps: reps', userId, weight: weight' }
                              ExistingSet id ->
                                Api.updateSet { id, reps: reps', userId, weight: weight' }
                          for_ mExercise \exercise' ->
                            liftEffect do
                              setWeight ""
                              setReps ""
                              setView $ AddSets
                                { exerciseKind
                                , modal: case mSet of
                                    Just _ -> Nothing
                                    Nothing -> Just NewSet
                                , session: session
                                    { exercises = session.exercises #
                                        updateWhere (eq exerciseKind.kind <<< _.kind) exercise'
                                    }
                                }
                    }
                    case mSet of
                      Just _ -> "Save"
                      Nothing -> "Next set →"
                , htmlIf (isNothing mSet) $
                    H.button_ "btn btn-outline-primary px-4 mt-3"
                      { onClick: fromMaybe (pure unit) do
                          weight' <- Number.fromString weight
                          reps' <- Int.fromString reps
                          pure $ launchAff_ do
                            mExercise <-
                              case editSetModal of
                                NewSet ->
                                  Api.addSet { exerciseId: exercise.id, reps: reps', userId, weight: weight' }
                                ExistingSet id ->
                                  Api.updateSet { id, reps: reps', userId, weight: weight' }
                            for_ mExercise \exercise' ->
                              liftEffect $ setView $ AddExercises
                                { session: session
                                    { exercises = session.exercises #
                                        updateWhere (eq exerciseKind.kind <<< _.kind) exercise'
                                    }
                                , modal: false
                                }
                      }
                      "Done"
                ]
            , onDismiss: setView $ AddSets { exerciseKind, modal: Nothing, session }
            , title: "How’d set " <> show (setIndex + 1) <> " go?"
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
