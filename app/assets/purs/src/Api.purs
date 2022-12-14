module Api
  ( authenticityToken
  )
  where

import Effect (Effect)

foreign import authenticityToken :: Effect String
