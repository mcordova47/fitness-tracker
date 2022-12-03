module Utils.Array
  ( modifyWhere
  , updateWhere
  )
  where

import Prelude

updateWhere :: forall a. (a -> Boolean) -> a -> Array a -> Array a
updateWhere predicate newValue =
  modifyWhere predicate (const newValue)

modifyWhere :: forall a. (a -> Boolean) -> (a -> a) -> Array a -> Array a
modifyWhere predicate f xs =
  xs <#> \x -> if predicate x then f x else x
