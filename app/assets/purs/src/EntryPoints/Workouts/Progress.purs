module EntryPoints.Workouts.Progress
  ( boot
  )
  where

import Elmish.Boot (BootRecord)
import Layout as Layout
import Pages.Progress as Progress

type Props =
  { activePage :: String
  , userId :: String
  }

boot :: BootRecord Props
boot = Layout.bootPage \props ->
  Progress.view { userId: props.userId }
