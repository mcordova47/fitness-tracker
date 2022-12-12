module Components.ReactSelect.CreatableSelect
  ( Option
  , Props
  , creatableSelect
  )
  where

import Prelude

import Data.Nullable (Nullable)
import Data.Undefined.NoProblem (Opt)
import Data.Undefined.NoProblem.Closed as Closed
import Elmish (EffectFn1, ReactElement, createElement')
import Elmish.React.Import (ImportedReactComponent)

type Props =
  { defaultValue :: Opt (Nullable Option)
  , onChange :: EffectFn1 Option Unit
  , onCreateOption :: EffectFn1 String Unit
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
