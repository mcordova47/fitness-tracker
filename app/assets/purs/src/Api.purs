module Api
  ( Exercise
  , MuscleGroup
  , Session
  , Session'
  , Set
  , addSet
  , createExercise
  , createSession
  , lastExercise
  , lastSession
  , sessions
  , todaysSession
  , updateSet
  )
  where

import Prelude

import Affjax.RequestBody as RequestBody
import Affjax.ResponseFormat (json)
import Affjax.Web as Affjax
import Data.Argonaut.Core as Json
import Data.Either (hush)
import Data.Int as Int
import Data.JSDate (JSDate)
import Data.JSDate as JSDate
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Data.Traversable (for)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Foreign.Object as FO
import Unsafe.Coerce (unsafeCoerce)

type Session = Session' JSDate
type SessionRaw = Session' String
type Session' date =
  { date :: date
  , muscleGroup :: MuscleGroup
  , exercises :: Array Exercise
  }

type Exercise =
  { id :: Int
  , kind :: String
  , sets :: Array Set
  }

type Set =
  { id :: Int
  , reps :: Int
  , weight :: Number
  }

type MuscleGroup =
  { id :: Int
  , name :: String
  }

sessions :: String -> Aff (Maybe (Array Session))
sessions userId = do
  raw <- Affjax.get json $ "/" <> userId <> "/workouts/sessions"
  for (hush raw) \{ body } ->
    for (unsafeCoerce body :: Array SessionRaw) \session -> do -- TODO: Use argonaut instead of `unsafeCoerce`
      date <- liftEffect $ JSDate.parse session.date
      pure session { date = date }

todaysSession :: String -> Aff (Maybe Session)
todaysSession userId = do
  raw <- Affjax.get json $ "/" <> userId <> "/workouts/todays_session"
  join <$> for (hush raw) \{ body } ->
    for (Nullable.toMaybe (unsafeCoerce body :: Nullable SessionRaw)) \session -> do -- TODO: Use argonaut instead of `unsafeCoerce`
      date <- liftEffect $ JSDate.parse session.date
      pure session { date = date }

lastSession :: String -> MuscleGroup -> Aff (Maybe Session)
lastSession userId muscleGroup = do
  raw <- Affjax.get json $ "/" <> userId <> "/workouts/last_session" <> "?muscle_group=" <> show muscleGroup.id
  join <$> for (hush raw) \{ body } ->
    for (Nullable.toMaybe (unsafeCoerce body :: Nullable SessionRaw)) \session -> do -- TODO: Use argonaut instead of `unsafeCoerce`
      date <- liftEffect $ JSDate.parse session.date
      pure session { date = date }

lastExercise :: String -> String -> Aff (Maybe Exercise)
lastExercise userId kind = do
  raw <- Affjax.get json $ "/" <> userId <> "/workouts/last_exercise" <> "?kind=" <> kind
  pure $ hush raw <#> \{ body } -> unsafeCoerce body :: Exercise -- TODO: Use argonaut instead of `unsafeCoerce`

createSession :: { userId :: String, muscleGroup :: String } -> Aff (Maybe Session)
createSession { userId, muscleGroup } = do
  token <- liftEffect authenticityToken
  raw <- Affjax.post json ("/" <> userId <> "/workouts/create_session") $
    Just $ RequestBody.json $ Json.fromObject $ FO.fromHomogeneous
      { muscle_group: Json.fromString muscleGroup
      , authenticity_token: Json.fromString token
      }
  for (hush raw) \{ body } -> do
    let session = unsafeCoerce body :: SessionRaw -- TODO: Use argonaut instead of `unsafeCoerce`
    date <- liftEffect $ JSDate.parse session.date
    pure session { date = date }

createExercise :: { userId :: String, kind :: String } -> Aff (Maybe Exercise)
createExercise { userId, kind } = do
  token <- liftEffect authenticityToken
  raw <- Affjax.post json ("/" <> userId <> "/workouts/create_exercise") $
    Just $ RequestBody.json $ Json.fromObject $ FO.fromHomogeneous
      { exercise_kind: Json.fromString kind
      , authenticity_token: Json.fromString token
      }
  pure $ hush raw <#> \{ body } -> unsafeCoerce body :: Exercise -- TODO: Use argonaut instead of `unsafeCoerce`

addSet :: { exerciseId :: Int, reps :: Int, userId :: String, weight :: Number } -> Aff (Maybe Exercise)
addSet { exerciseId, reps, userId, weight } = do
  token <- liftEffect authenticityToken
  raw <- Affjax.post json ("/" <> userId <> "/workouts/add_set") $
    Just $ RequestBody.json $ Json.fromObject $ FO.fromHomogeneous
      { exercise_id: Json.fromNumber $ Int.toNumber exerciseId
      , reps: Json.fromNumber $ Int.toNumber reps
      , weight: Json.fromNumber weight
      , authenticity_token: Json.fromString token
      }
  pure $ hush raw <#> \{ body } -> unsafeCoerce body :: Exercise -- TODO: Use argonaut instead of `unsafeCoerce`

updateSet :: { id :: Int, reps :: Int, userId :: String, weight :: Number } -> Aff (Maybe Exercise)
updateSet { id, reps, userId, weight } = do
  token <- liftEffect authenticityToken
  raw <- Affjax.post json ("/" <> userId <> "/workouts/update_set") $
    Just $ RequestBody.json $ Json.fromObject $ FO.fromHomogeneous
      { id: Json.fromNumber $ Int.toNumber id
      , reps: Json.fromNumber $ Int.toNumber reps
      , weight: Json.fromNumber weight
      , authenticity_token: Json.fromString token
      }
  pure $ hush raw <#> \{ body } -> unsafeCoerce body :: Exercise -- TODO: Use argonaut instead of `unsafeCoerce`

foreign import authenticityToken :: Effect String
