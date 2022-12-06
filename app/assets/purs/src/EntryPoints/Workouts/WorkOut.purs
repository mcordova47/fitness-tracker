module EntryPoints.Workouts.WorkOut
  ( boot
  )
  where

import Elmish.Boot (BootRecord)
import Layout as Layout
import Pages.Workouts.WorkOut as WorkOut
import Types.Workouts.ExerciseKind (ExerciseKind)
import Types.Workouts.MuscleGroup (MuscleGroup)

type Props =
  { currentPath :: String
  , exerciseKinds :: Array ExerciseKind
  , muscleGroups :: Array MuscleGroup
  , userId :: String
  }

boot :: BootRecord Props
boot = Layout.bootPage \props ->
  WorkOut.view
    { exerciseKinds: props.exerciseKinds
    , muscleGroups: props.muscleGroups
    , userId: props.userId
    }
