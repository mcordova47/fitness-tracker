module Components.Recharts.ResponsiveContainer
  ( Size(..)
  , percent
  , pixels
  , responsiveContainer
  )
  where

import Prelude

import Data.Undefined.NoProblem (Opt)
import Data.Undefined.NoProblem.Closed as Closed
import Elmish (ReactElement, createElement)
import Elmish.Foreign (class CanPassToJavaScript)
import Elmish.React (class ReactChildren)
import Elmish.React.Import (ImportedReactComponent)
import Unsafe.Coerce (unsafeCoerce)

type Props =
  { height :: Opt Size
  , width :: Opt Size
  }

data Size
instance CanPassToJavaScript Size

percent :: Number -> Size
percent n = unsafeCoerce (show n <> "%")

pixels :: Number -> Size
pixels = unsafeCoerce

responsiveContainer :: forall props c. Closed.Coerce props Props => ReactChildren c => props -> c -> ReactElement
responsiveContainer props = createElement responsiveContainer_ props'
  where
    props' = Closed.coerce props :: Props

foreign import responsiveContainer_ :: ImportedReactComponent
