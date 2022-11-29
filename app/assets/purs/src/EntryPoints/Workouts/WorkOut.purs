module EntryPoints.Workouts.WorkOut
  ( boot
  )
  where

import Elmish.Boot (BootRecord)
import Layout as Layout
import Pages.WorkOut as WorkOut

type Props =
  { activePage :: String
  , userId :: String
  }

boot :: BootRecord Props
boot = Layout.bootPage \props ->
  WorkOut.view { userId: props.userId }
