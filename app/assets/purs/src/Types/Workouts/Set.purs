module Types.Workouts.Set
  ( Set
  )
  where

type Set =
  { id :: Int
  , reps :: Int
  , weight :: Number
  }
