module EntryPoints.Main.Landing
  ( boot
  )
  where

import Elmish.Boot (BootRecord)
import Layout as Layout
import Layout.Nav as Nav
import Pages.Main.Landing as Landing

type Props =
  { currentPath :: String
  -- TODO: Add userId :: Maybe String
  }

boot :: BootRecord Props
boot = Layout.bootPage' \{ currentPath } ->
  { body: Landing.view {}
  , nav: Nav.view'
      { currentPath
      , links:
          [ { label: "Work out", url: "/workout" }
          ]
      , mainUrl: "/"
      }
  }
