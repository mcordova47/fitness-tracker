module Components.Recharts.CartesianGrid
  ( Props
  , cartesianGrid
  )
  where

import Data.Undefined.NoProblem (Opt)
import Data.Undefined.NoProblem.Closed as Closed
import Elmish (ReactElement, createElement')
import Elmish.React.Import (ImportedReactComponent)

type Props =
  { strokeDasharray :: Opt String
  }

cartesianGrid :: forall props. Closed.Coerce props Props => props -> ReactElement
cartesianGrid props = createElement' cartesianGrid_ props'
  where
    props' = Closed.coerce props :: Props

foreign import cartesianGrid_ :: ImportedReactComponent
