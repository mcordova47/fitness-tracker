module Components.Table
  ( table
  , tbody
  , tbodyRow
  , tbodyRow_
  , td
  , th
  , thRow
  , thead
  , theadRow
  )
  where

import Prelude

import Elmish (ReactElement)
import Elmish.HTML (Props_tr)
import Elmish.HTML.Internal (StyledTag_)
import Elmish.HTML.Styled as H
import Elmish.React (class ReactChildren)

table :: ∀ content. ReactChildren content => String -> content -> ReactElement
table className =
  H.table $ "table-auto min-w-full " <> className

thead :: ∀ content. ReactChildren content => String -> content -> ReactElement
thead className =
  H.thead $ "border-b " <> className

theadRow :: ∀ content. ReactChildren content => String -> content -> ReactElement
theadRow =
  H.tr

th :: ∀ content. ReactChildren content => String -> content -> ReactElement
th className =
  H.th_ ("text-sm font-medium px-6 py-4 text-left " <> className) { scope: "col" }

tbody :: ∀ content. ReactChildren content => String -> content -> ReactElement
tbody =
  H.tbody

tbodyRow :: ∀ content. ReactChildren content => String -> content -> ReactElement
tbodyRow className =
  tbodyRow_ className {}

tbodyRow_ :: StyledTag_ Props_tr
tbodyRow_ className =
  H.tr_ $ "border-b " <> className

td :: ∀ content. ReactChildren content => String -> content -> ReactElement
td className =
  H.td $ "px-6 py-4 whitespace-nowrap text-sm " <> className

thRow :: ∀ content. ReactChildren content => String -> content -> ReactElement
thRow className =
  H.th_ ("font-medium px-6 py-4 whitespace-nowrap text-sm text-left " <> className) { scope: "row" }
