module Components.BrowserEvents
  ( Event
  , Props
  , browserEvents
  ) where


import Data.Undefined.NoProblem (Opt)
import Elmish (createElement')
import Elmish.HTML.Events as E
import Elmish.React.Import (ImportedReactComponent, ImportedReactComponentConstructor)
import Foreign (Foreign)

type Event = Foreign

type Props =
  ( mouseup :: Opt (E.EventHandler E.MouseEvent)
  )

browserEvents :: ImportedReactComponentConstructor Props
browserEvents = createElement' _browserEvents

foreign import _browserEvents :: ImportedReactComponent
