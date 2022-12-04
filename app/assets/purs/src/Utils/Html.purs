module Utils.Html
  ( (&.>)
  , (&>)
  , htmlIf
  , maybeHtml
  )
  where

import Data.Maybe (Maybe, maybe)
import Elmish (ReactElement)
import Elmish.HTML.Styled as H

htmlIf :: Boolean -> ReactElement -> ReactElement
htmlIf p content =
  if p then content else H.empty

infixr 2 htmlIf as &>

maybeHtml :: ∀ a. Maybe a -> (a -> ReactElement) -> ReactElement
maybeHtml x f =
  maybe H.empty f x

infixr 2 maybeHtml as &.>
