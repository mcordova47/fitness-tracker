module Components.Input
  ( input
  )
  where

import Prelude

import Elmish.HTML (Props_input)
import Elmish.HTML.Internal (StyledTagNoContent_)
import Elmish.HTML.Styled as H

input :: StyledTagNoContent_ Props_input
input className =
  H.input_ $ "block w-full px-3 py-1.5 text-base font-normal bg-white bg-clip-padding dark:bg-slate-700 border border-solid border-slate-300 dark:border-slate-600 rounded m-0 focus:border-cyan-600 focus:outline-none " <> className