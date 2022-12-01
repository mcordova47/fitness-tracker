module Utils.Html
  ( (?>)
  , htmlIf
  )
  where

import Elmish (ReactElement)
import Elmish.HTML.Styled as H

htmlIf :: Boolean -> ReactElement -> ReactElement
htmlIf p content =
  if p then content else H.empty

infixr 2 htmlIf as ?>
