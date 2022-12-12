module Components.ListGroup
  ( listGroup
  , listItem
  , listItemLink
  )
  where

import Prelude

import Elmish (ReactElement)
import Elmish.HTML (Props_a)
import Elmish.HTML.Internal (StyledTag_)
import Elmish.HTML.Styled as H
import Elmish.React (class ReactChildren)

listGroup :: ∀ content. ReactChildren content => String -> content -> ReactElement
listGroup className =
  H.div $ "bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700 " <> className

listItem :: ∀ content. ReactChildren content => String -> content -> ReactElement
listItem className =
  H.div $ "px-6 py-2 w-full border-b border-slate-200 dark:border-slate-700 first:rounded-t-lg last:rounded-b-lg last:border-none " <> className

listItemLink :: StyledTag_ Props_a
listItemLink className =
  H.a_ $ "block px-6 py-2 w-full border-b border-slate-200 dark:border-slate-700 hover:bg-slate-100 hover:text-slate-500 dark:hover:text-white dark:hover:bg-slate-700 first:rounded-t-lg last:rounded-b-lg last:border-none cursor-pointer " <> className
