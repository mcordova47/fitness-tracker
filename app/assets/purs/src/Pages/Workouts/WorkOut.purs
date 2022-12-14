module Pages.Workouts.WorkOut
  ( view
  )
  where

import Prelude

import Api.Workouts as Api
import Components.Card (card)
import Components.Input (input)
import Components.ListGroup (listGroup, listItem, listItemLink)
import Components.ReactSelect.CreatableSelect (creatableSelect)
import Components.Table (table, tbody, tbodyRow, tbodyRow_, td, th, thRow, thead, theadRow)
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
    H.div "max-w-7xl mx-auto py-4" case view' of
      Loading ->
        H.empty
      ChooseMuscleGroup { modal } ->
        H.fragment
        [ H.h3 "text-3xl" "New session"
        , H.p "text-slate-500 dark:text-white"
          [ H.button_ "text-blue-500 underline dark:text-white"
              { onClick: setView $ ChooseMuscleGroup { modal: true } }
              "Choose a muscle group"
          , H.text " to begin."
          ]
        , modal &>
            modal'
              { content:
                  creatableSelect
                    { defaultValue: Nullable.null
                    , onChange: createSession setView setLastSession _.value
                    , onCreateOption: createSession setView setLastSession identity
                    , options: muscleGroups <#> \{ name } -> { label: name, value: name }
                    , placeholder: "Select muscle group"
                    }
              , onDismiss: setView $ ChooseMuscleGroup { modal: false }
              , title: "Which muscle group are you working out today?"
              }
        ]
      AddExercises { session, modal } ->
        H.fragment
        [ H.h3 "text-3xl mb-3" $ session.muscleGroup.name <> " day"
        , null session.exercises &>
            H.div "text-muted mb-1" "Add some exercises below to get started"
        , listGroup ""
          [ H.fragment $ session.exercises # Array.mapWithIndex \index exercise ->
              listItemLink ("group flex justify-between" <> if null exercise.sets then "" else " text-green-600 dark:text-green-500")
                { onClick: setView $ AddSets
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
                , H.div "md:hidden md:group-hover:block" $
                    H.button_ "text-sm"
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
                      } $
                      H.span "fa fa-close" H.empty
                ]
          , listItemLink ""
              { onClick: setView $ AddExercises { session, modal: true } }
              "+ Add an exercise"
          ]
        , lastSession &.> \{ id, exercises } ->
            H.fragment
            [ H.h5 "text-xl mt-10 mb-2"
              [ H.text "Here’s what you did last time "
              , null session.exercises &>
                  H.button_ "text-blue-500 dark:text-white underline text-base"
                    { onClick: launchAff_ do
                        Api.copySessionToToday { sessionId: id, userId } >>= traverse_ \session' ->
                          liftEffect $ setView $ AddExercises { session: session', modal: false }
                    }
                    "(Copy to today’s session)"
              ]
            , listGroup "" $
                exercises <#> \exercise ->
                  listItem ""
                  [ H.text exercise.kind
                  , H.span "text-slate-500 dark:text-white"
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
        -- TODO: Parallelize
        fetchLastExercise exerciseKind.kind setLastExercise
        fetchMaxSet exerciseKind.kind setMaxSet

      Hooks.pure $
        H.fragment
        [ H.div "mb-3"
          [ H.a_ "text-blue-500 dark:text-white cursor-pointer"
              { onClick: setView $ AddExercises { session, modal: false }
              } $
              H.h3 "text-3xl inline-block underline underline-offset-2" $ session.muscleGroup.name <> " day"
          , H.h5 "text-2xl inline-block ml-2" $ "> " <> exerciseKind.kind
          ]
        , fromMaybe H.empty do
            exercise <- session.exercises # find (eq exerciseKind.kind <<< _.kind)
            pure $ H.fragment
              [ null exercise.sets &>
                  H.div "text-slate-500 dark:text-white mb-1" "Add a new set below to get started"
              , table ""
                [ thead "" $
                    theadRow ""
                    [ th "" "Weight"
                    , th "" "Reps"
                    ]
                , tbody ""
                  [ H.fragment $ exercise.sets <#> \set ->
                      tbodyRow_ "cursor-pointer hover:bg-slate-100 hover:text-slate-500 dark:hover:bg-slate-800 dark:hover:text-white"
                      { onClick: setView $ AddSets { exerciseKind, modal: Just $ ExistingSet set.id, session }
                      }
                      [ thRow "" $ show set.weight
                      , td "" $ show set.reps
                      ]
                  , tbodyRow_ "cursor-pointer hover:bg-slate-100 hover:text-slate-500 dark:hover:bg-slate-800 dark:hover:text-white"
                    { onClick: setView $ AddSets { exerciseKind, modal: Just NewSet, session } }
                    [ thRow "" "+ Add a set"
                    , td "" H.empty
                    ]
                  ]
                ]
              , H.div "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-16"
                [ lastExercise &.> \ex ->
                    H.div "col-span-1 lg:col-span-2" $
                      card "" $
                      [ H.h5 "text-xl mb-3" "Here’s what you did last time"
                      , table ""
                        [ thead "" $
                            theadRow ""
                            [ th "" "Weight"
                            , th "" "Reps"
                            ]
                        , tbody "" $
                            ex.sets <#> \set ->
                              tbodyRow ""
                              [ thRow "" $ show set.weight
                              , td "" $ show set.reps
                              ]
                        ]
                      ]
                , maxSet &.> \{ weight, reps } ->
                    H.div "col-span-1" $
                      card "mb-3" $
                      [ H.h5 "text-xl mb-3" "All-time max"
                      , H.div "columns-2 gap-3 mt-3"
                        [ H.div ""
                          [ H.h6 "text-lg text-slate-500 dark:text-white mb-2" "Weight"
                          , H.div "text-6xl font-light" $ show weight
                          ]
                        , H.div ""
                          [ H.h6 "text-lg text-slate-500 dark:text-white mb-2" "Reps"
                          , H.div "text-6xl font-light" $ show reps
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
                [ H.div "grid grid-cols-4"
                  [ H.div "col-span-1" $
                      H.label_ "form-label mb-0"
                        { htmlFor: "weight-input" }
                        "Weight"
                  , H.div "col-span-3" $
                      input ""
                        { id: "weight-input"
                        , onChange: setWeight <?| eventTargetValue
                        , type: "number"
                        , value: weight
                        , min: "0"
                        , autoFocus: true
                        , key: "weight-input-" <> show setIndex
                        -- ^ Key helps autoFocus work when going from one set to the next
                        }
                  ]
                , H.div "grid grid-cols-4 mt-3"
                  [ H.div "col-span-1" $
                      H.label_ "form-label mb-0"
                        { htmlFor: "reps-input" }
                        "Reps"
                  , H.div "col-span-3" $
                      input ""
                        { id: "reps-input"
                        , onChange: setReps <?| eventTargetValue
                        , type: "number"
                        , value: reps
                        , min: "0"
                        , step: "1"
                        }
                  ]
                , H.button_ "bg-cyan-600 rounded-md text-white px-4 py-1 mt-3 mr-3"
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
                    H.button_ "border border-cyan-600 text-cyan-600 dark:text-white rounded-md px-4 py-1 mt-3"
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
      [ H.div "fixed inset-0 z-30 flex justify-center items-center" $
          H.div "bg-white dark:bg-slate-800 max-w-2xl w-full mx-3 rounded-lg"
          [ H.div "p-3 dark:bg-slate-700 border-b border-slate-200 dark:border-none flex justify-between rounded-t-lg"
            [ H.h4 "text-2xl" title
            , H.button_ "" { onClick: onDismiss } $
                H.span "fa fa-close" H.empty
            ]
          , H.div "p-3" content
          ]
      , H.div "fixed inset-0 z-10 bg-slate-900 opacity-80" H.empty
      ]
