module Utils.String
  ( Plural(..)
  , Singular(..)
  , pluralize
  )
  where

import Prelude

newtype Plural = Plural String
newtype Singular = Singular String

pluralize :: Int -> Singular -> Plural -> String
pluralize n (Singular s) (Plural p) =
  if n == 1 then s else p
