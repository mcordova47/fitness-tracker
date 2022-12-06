module Types.Workouts.Session
  ( Session
  , Session'
  , SessionRaw
  )
  where

import Data.JSDate (JSDate)
import Types.Workouts.Exercise (Exercise)
import Types.Workouts.MuscleGroup (MuscleGroup)

type Session = Session' JSDate
type SessionRaw = Session' String
type Session' date =
  { id :: Int
  , date :: date
  , muscleGroup :: MuscleGroup
  , exercises :: Array Exercise
  }
