module Components.Recharts.Line
  ( LineType
  , basis
  , basisClosed
  , basisOpen
  , line
  , linear
  , linearClosed
  , monotone
  , monotoneX
  , monotoneY
  , natural
  , step
  , stepAfter
  , stepBefore
  )
  where

import Data.Undefined.NoProblem (Opt)
import Data.Undefined.NoProblem.Closed as Closed
import Elmish (ReactElement, createElement')
import Elmish.Foreign (class CanPassToJavaScript)
import Elmish.React.Import (ImportedReactComponent)

type LineProps =
  { type :: Opt LineType
  , dataKey :: String
  }

newtype LineType = LineType String
instance CanPassToJavaScript LineType
basis = LineType "basis" :: LineType
basisClosed = LineType "basisClosed" :: LineType
basisOpen = LineType "basisOpen" :: LineType
linear = LineType "linear" :: LineType
linearClosed = LineType "linearClosed" :: LineType
natural = LineType "natural" :: LineType
monotoneX = LineType "monotoneX" :: LineType
monotoneY = LineType "monotoneY" :: LineType
monotone = LineType "monotone" :: LineType
step = LineType "step" :: LineType
stepBefore = LineType "stepBefore" :: LineType
stepAfter = LineType "stepAfter" :: LineType

line :: forall props. Closed.Coerce props LineProps => props -> ReactElement
line props = createElement' line_ props'
  where
    props' = Closed.coerce props :: LineProps

foreign import line_ :: ImportedReactComponent
