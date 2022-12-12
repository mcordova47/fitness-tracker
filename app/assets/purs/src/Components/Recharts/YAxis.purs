module Components.Recharts.YAxis where

import Components.Recharts.Types.DataKey (DataKey)
import Data.Undefined.NoProblem (Opt)
import Data.Undefined.NoProblem.Closed as Closed
import Elmish (ReactElement, createElement')
import Elmish.React.Import (ImportedReactComponent)

type Props =
  { dataKey :: Opt DataKey
  , tick :: Opt ReactElement
  }

yAxis :: forall props. Closed.Coerce props Props => props -> ReactElement
yAxis props = createElement' yAxis_ props'
  where
    props' = Closed.coerce props :: Props

foreign import yAxis_ :: ImportedReactComponent
