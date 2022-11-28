module Components.Recharts.Types.DataKey
  ( DataKey
  , dataKeyFunction
  , dataKeyInt
  , dataKeyString
  )
  where

import Prelude

import Data.Function.Uncurried (mkFn1)
import Data.Maybe (Maybe)
import Data.Nullable (toNullable)
import Elmish.Foreign (class CanPassToJavaScript)
import Unsafe.Coerce (unsafeCoerce)

data DataKey
instance CanPassToJavaScript DataKey

dataKeyFunction :: forall a. (a -> Maybe Number) -> DataKey
dataKeyFunction = unsafeCoerce <<< mkFn1 <<< (_ >>> toNullable)

dataKeyString :: String -> DataKey
dataKeyString = unsafeCoerce

dataKeyInt :: Int -> DataKey
dataKeyInt = unsafeCoerce
