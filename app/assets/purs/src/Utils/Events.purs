module Utils.Events
  ( eventTargetValue
  )
  where

import Prelude

import Data.Maybe (Maybe(..))
import Elmish.Foreign (readForeign)
import Foreign (Foreign)

eventTargetValue :: Foreign -> Maybe String
eventTargetValue f = do
  e :: { target :: { value :: _ } } <- readForeign f
  Just e.target.value
