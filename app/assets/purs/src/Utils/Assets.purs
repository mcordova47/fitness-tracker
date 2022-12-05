module Utils.Assets where

import Prelude

assetPath :: String -> String
assetPath path =
  assetRoot <> path

foreign import assetRoot :: String
