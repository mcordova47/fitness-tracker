module Layout
  ( bootPage
  , bootPage'
  )
  where

import Prelude

import Elmish (ReactElement, BootRecord)
import Elmish.HTML.Styled as H
import Layout.Nav as Nav
import Utils.Boot (bootPure)

bootPage :: ∀ r. (Nav.Props r -> ReactElement) -> BootRecord (Nav.Props r)
bootPage body =
  bootPage' \props -> { nav: Nav.view props, body: body props }

bootPage' :: ∀ props. (props -> { body :: ReactElement, nav :: ReactElement }) -> BootRecord props
bootPage' f =
  bootPure (view <<< f)

view :: { body :: ReactElement, nav :: ReactElement } -> ReactElement
view { body, nav } =
  H.div "pt-3 px-3 h-100 d-flex flex-column"
  [ nav
  , H.div "flex-grow-1" body
  ]
