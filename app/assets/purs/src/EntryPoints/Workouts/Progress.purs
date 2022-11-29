module EntryPoints.Workouts.Progress
  ( boot
  )
  where

import Prelude

import Elmish.Boot (BootRecord)
import Layout as Layout
import Pages.Charts as Charts
import Utils.Boot (bootPure)

type Props =
  { activePage :: String
  , userId :: String
  }

boot :: BootRecord Props
boot = bootPure \{ activePage, userId } ->
  Layout.view { activePage, userId } $
    Charts.view { userId }
