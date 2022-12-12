module Components.Recharts.Tick
  ( tick
  )
  where

import Elmish (ReactElement, createElement')
import Elmish.React.Import (ImportedReactComponent)

tick :: {} -> ReactElement
tick = createElement' tick_

foreign import tick_ :: ImportedReactComponent
