module Components.Recharts.Tooltip
  ( LabelFormatter(..)
  , Props
  , labelFormatter
  , tooltip
  )
  where

import Data.Undefined.NoProblem (Opt)
import Data.Undefined.NoProblem.Closed as Closed
import Elmish (ReactElement, createElement')
import Elmish.Foreign (class CanPassToJavaScript)
import Elmish.HTML (CSS)
import Elmish.React.Import (ImportedReactComponent)
import Unsafe.Coerce (unsafeCoerce)

type Props =
  { contentStyle :: Opt CSS
  , labelFormatter :: Opt LabelFormatter
  }

data LabelFormatter
instance CanPassToJavaScript LabelFormatter

labelFormatter :: forall a. (a -> String) -> LabelFormatter
labelFormatter = unsafeCoerce

tooltip :: ∀ props. Closed.Coerce props Props => props -> ReactElement
tooltip props' = createElement' tooltip_ props
  where
    props = Closed.coerce props' :: Props

foreign import tooltip_ :: ImportedReactComponent
