module Api
  ( Exercise
  , Session
  , Session'
  , Set
  , saveSession
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
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Foreign.Object as FO
import Unsafe.Coerce (unsafeCoerce)

type Session = Session' JSDate
type SessionRaw = Session' String
type Session' date =
  { date :: date
  , muscleGroup :: String
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
  raw <- Affjax.get json $ "http://localhost:3000/" <> userId <> "/workouts/sessions" -- TODO: Fix URL
  for (hush raw) \{ body } ->
    for (unsafeCoerce body :: Array SessionRaw) \session -> do -- TODO: Use argonaut instead of `unsafeCoerce`
      date <- liftEffect $ JSDate.parse session.date
      pure session { date = date }

todaysSession :: String -> Aff (Maybe Session)
todaysSession userId = do
  raw <- Affjax.get json $ "http://localhost:3000/" <> userId <> "/workouts/todays_session" -- TODO: Fix URL
  join <$> for (hush raw) \{ body } ->
    for (Nullable.toMaybe (unsafeCoerce body :: Nullable SessionRaw)) \session -> do -- TODO: Use argonaut instead of `unsafeCoerce`
      date <- liftEffect $ JSDate.parse session.date
      pure session { date = date }

saveSession :: { userId :: String, muscleGroup :: String } -> Aff (Maybe Session)
saveSession { userId, muscleGroup } = do
  raw <- Affjax.post json ("http://localhost:3000/" <> userId <> "/workouts/save_session") $ -- TODO: Fix URL
    Just $ RequestBody.json $ Json.fromObject $ FO.fromHomogeneous { muscle_group: Json.fromString muscleGroup }
  for (hush raw) \{ body } -> do
    let session = unsafeCoerce body :: SessionRaw -- TODO: Use argonaut instead of `unsafeCoerce`
    date <- liftEffect $ JSDate.parse session.date
    pure session { date = date }
