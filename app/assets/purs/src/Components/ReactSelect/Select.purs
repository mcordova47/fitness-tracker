module Components.ReactSelect.Select
  ( Option
  , Props
  , select
  )
  where

import Prelude

import Data.Nullable (Nullable)
import Data.Undefined.NoProblem (Opt)
import Data.Undefined.NoProblem.Closed as Closed
import Elmish (EffectFn1, ReactElement, createElement')
import Elmish.React.Import (ImportedReactComponent)

type Props =
  { onChange :: EffectFn1 Option Unit
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
