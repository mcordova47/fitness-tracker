module Components.Recharts.Tooltip
  ( Props
  , tooltip
  )
  where

import Elmish (ReactElement, createElement')
import Elmish.React.Import (ImportedReactComponent)

type Props = {}

tooltip :: Props -> ReactElement
tooltip = createElement' tooltip_

foreign import tooltip_ :: ImportedReactComponent
