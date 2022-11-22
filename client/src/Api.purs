module Api
  ( Exercise
  , Session
  , Session'
  , Set
  , sessions
  )
  where

import Prelude

import Affjax.ResponseFormat (json)
import Affjax.Web as Affjax
import Data.Either (hush)
import Data.JSDate (JSDate)
import Data.JSDate as JSDate
import Data.Maybe (Maybe)
import Data.Traversable (for)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
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
sessions id = do
  raw <- Affjax.get json $ "http://localhost:3000/workouts/sessions?slug=" <> id -- TODO: Fix URL
  for (hush raw) \{ body } ->
    for (unsafeCoerce body :: Array SessionRaw) \session -> do -- TODO: Use argonaut
      date <- liftEffect $ JSDate.parse session.date
      pure session { date = date }
