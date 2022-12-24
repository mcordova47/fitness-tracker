module Components.ReactSelect.Select
  ( Option
  , Props
  , select
  )
  where


import Data.Nullable (Nullable)
import Data.Undefined.NoProblem (Opt)
import Data.Undefined.NoProblem.Closed as Closed
import Elmish (ReactElement, createElement')
import Elmish.HTML.Events as E
import Elmish.React.Import (ImportedReactComponent)

type Props =
  { onChange :: E.EventHandler Option
  , options :: Array Option
  , placeholder :: Opt String
  , value :: Opt (Nullable Option)
  , defaultValue :: Opt (Nullable Option)
  }

type Option =
  { label :: String
  , value :: String
  }

select :: ∀ props. Closed.Coerce props Props => props -> ReactElement
select props = createElement' select_ props'
  where
    props' = Closed.coerce props :: Props

foreign import select_ :: ImportedReactComponent
