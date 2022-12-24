module Components.ReactSelect.CreatableSelect
  ( Option
  , Props
  , creatableSelect
  )
  where


import Data.Nullable (Nullable)
import Data.Undefined.NoProblem (Opt)
import Data.Undefined.NoProblem.Closed as Closed
import Elmish (ReactElement, createElement')
import Elmish.HTML.Events as E
import Elmish.React.Import (ImportedReactComponent)

type Props =
  { defaultValue :: Opt (Nullable Option)
  , onChange :: E.EventHandler Option
  , onCreateOption :: E.EventHandler String
  , options :: Array Option
  , placeholder :: Opt String
  , value :: Opt (Nullable Option)
  }

type Option =
  { label :: String
  , value :: String
  }

creatableSelect :: ∀ props. Closed.Coerce props Props => props -> ReactElement
creatableSelect props = createElement' creatableSelect_ props'
  where
    props' = Closed.coerce props :: Props

foreign import creatableSelect_ :: ImportedReactComponent
