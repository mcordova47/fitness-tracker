module EntryPoints.Workouts.WorkOut
  ( boot
  )
  where

import Elmish.Boot (BootRecord)
import Layout as Layout
import Pages.Workouts.WorkOut as WorkOut

type Props =
  { currentPath :: String
  , exerciseKinds :: Array { kind :: String }
  , muscleGroups :: Array { name :: String }
  , userId :: String
  }

boot :: BootRecord Props
boot = Layout.bootPage \props ->
  WorkOut.view
    { exerciseKinds: props.exerciseKinds
    , muscleGroups: props.muscleGroups
    , userId: props.userId
    }
