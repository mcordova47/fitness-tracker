module Api
  ( Exercise
  , Session
  , Session'
  , Set
  , createExercise
  , createSession
  , sessions
  , todaysSession
  )
  where

import Prelude

import Affjax.RequestBody as RequestBody
import Affjax.ResponseFormat (json)
import Affjax.Web as Affjax
import Data.Argonaut.Core as Json
import Data.Either (hush)
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
  , muscleGroup :: { name :: String }
  , exercises :: Array Exercise
  }

type Exercise =
  { kind :: String
  , sets :: Array Set
  }

type Set =
  { reps :: Int
  , weight :: Number
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

createExercise :: { userId :: String, kind :: String } -> Aff Unit
createExercise { userId, kind } = do
  token <- liftEffect authenticityToken
  _ <- Affjax.post json ("/" <> userId <> "/workouts/create_exercise") $
    Just $ RequestBody.json $ Json.fromObject $ FO.fromHomogeneous
      { exercise_kind: Json.fromString kind
      , authenticity_token: Json.fromString token
      }
  pure unit

foreign import authenticityToken :: Effect String
