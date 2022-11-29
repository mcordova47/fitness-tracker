module Layout
  ( bootPage
  )
  where

import Prelude

import Elmish (ReactElement, BootRecord)
import Elmish.HTML.Styled as H
import Layout.Nav as Nav
import Utils.Boot (bootPure)

bootPage :: ∀ r. (Nav.Props r -> ReactElement) -> BootRecord (Nav.Props r)
bootPage body = bootPure \props@{ activePage, userId } ->
  view { activePage, userId } $
    body props

view :: ∀ r. Nav.Props r -> ReactElement -> ReactElement
view navProps body =
  H.div "pt-3 px-3 h-100 d-flex flex-column"
  [ Nav.view navProps
  , H.div "flex-grow-1" body
  ]
