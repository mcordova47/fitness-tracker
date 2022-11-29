module EntryPoints.Workouts.Progress
  ( boot
  )
  where

import Prelude

import Elmish.Boot (BootRecord)
import Layout as Layout
import Pages.Progress as Progress
import Utils.Boot (bootPure)

type Props =
  { activePage :: String
  , userId :: String
  }

boot :: BootRecord Props
boot = bootPure \{ activePage, userId } ->
  Layout.view { activePage, userId } $
    Progress.view { userId }
