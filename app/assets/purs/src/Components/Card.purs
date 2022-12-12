module Components.Card
  ( card
  )
  where

import Prelude

import Elmish (ReactElement)
import Elmish.HTML.Styled as H
import Elmish.React (class ReactChildren)

card :: ∀ content. ReactChildren content => String -> content -> ReactElement
card className =
  H.div $ "rounded-lg border border-slate-200 dark:border-slate-700 dark:bg-slate-800 py-6 px-8 " <> className
