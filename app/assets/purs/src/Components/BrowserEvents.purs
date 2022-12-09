module Components.BrowserEvents
  ( Event
  , Props
  , browserEvents
  ) where

import Prelude

import Data.Undefined.NoProblem (Opt)
import Elmish (EffectFn1, createElement')
import Elmish.React.Import (ImportedReactComponent, ImportedReactComponentConstructor)
import Foreign (Foreign)

type Event = Foreign

type Props =
  ( mouseup :: Opt (EffectFn1 Event Unit)
  )

browserEvents :: ImportedReactComponentConstructor Props
browserEvents = createElement' _browserEvents

foreign import _browserEvents :: ImportedReactComponent
