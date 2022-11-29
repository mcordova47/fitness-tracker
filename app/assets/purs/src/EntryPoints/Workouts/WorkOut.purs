module EntryPoints.Workouts.WorkOut
  ( boot
  )
  where

import Prelude

import Elmish.Boot (BootRecord)
import Layout as Layout
import Pages.WorkOut as WorkOut
import Utils.Boot (bootPure)

type Props =
  { activePage :: String
  , userId :: String
  }

boot :: BootRecord Props
boot = bootPure \{ activePage, userId } ->
  Layout.view { activePage, userId } $
    WorkOut.view { userId }
