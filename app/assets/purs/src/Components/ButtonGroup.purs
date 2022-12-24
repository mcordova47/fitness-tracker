module Components.ButtonGroup where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Undefined.NoProblem (Opt, (!))
import Data.Undefined.NoProblem.Closed as Closed
import Elmish (Dispatch, ReactElement, (<|))
import Elmish.HTML.Styled as H

type Props value =
  { onClick :: Dispatch value
  , options :: Array { label :: String, value :: value }
  , value :: Maybe value
  , vertical :: Opt Boolean
  }

view :: ∀ props value. Closed.Coerce props (Props value) => Eq value => props -> ReactElement
view props' =
  H.div ("flex" <> if vertical then " flex-col" else "") $
    props.options <#> \{ value, label } ->
      H.button_
        ( "border-cyan-600 px-3 py-1"
        <> (if vertical then " first:rounded-t-md last:rounded-b-md border-x border-t last:border-b" else " first:rounded-l-md last:rounded-r-md border-y border-l last:border-r")
        <> (if props.value == Just value then " bg-cyan-600 text-white" else " text-cyan-600 dark:text-white")
        )
        { onClick: props.onClick <| \_ -> value
        }
        label
  where
    vertical = props.vertical ! false
    props = Closed.coerce props' :: Props value