module Types.Workouts.Exercise
  ( Exercise
  )
  where

import Types.Workouts.Set (Set)

type Exercise =
  { id :: Int
  , kind :: String
  , sets :: Array Set
  }
