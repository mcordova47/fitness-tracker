module Components.Recharts.XAxis
  ( Props
  , TickFormatter
  , tickFormatter
  , xAxis
  )
  where

import Prelude

import Components.Recharts.Types.DataKey (DataKey)
import Data.Function.Uncurried (mkFn1)
import Data.Undefined.NoProblem (Opt)
import Data.Undefined.NoProblem.Closed as Closed
import Elmish (ReactElement, createElement')
import Elmish.Foreign (class CanPassToJavaScript)
import Elmish.React.Import (ImportedReactComponent)
import Unsafe.Coerce (unsafeCoerce)

type Props =
  { dataKey :: Opt DataKey
  , tick :: Opt ReactElement
  , tickFormatter :: Opt TickFormatter
  }

data TickFormatter
instance CanPassToJavaScript TickFormatter

tickFormatter :: forall a. (a -> String) -> TickFormatter
tickFormatter = mkFn1 >>> unsafeCoerce

xAxis :: forall props. Closed.Coerce props Props => props -> ReactElement
xAxis props = createElement' xAxis_ props'
  where
    props' = Closed.coerce props :: Props

foreign import xAxis_ :: ImportedReactComponent
