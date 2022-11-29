module Utils.Boot
  ( bootPure
  )
  where

import Prelude

import Elmish (BootRecord, ReactElement, boot)

bootPure :: forall props. (props -> ReactElement) -> BootRecord props
bootPure view = boot \props ->
  { init: pure unit
  , update: \_ msg -> absurd msg
  , view: const $ const $ view props
  }
