module Pages.Charts
  ( view
  )
  where

import Prelude

import Components.Recharts.Line (line, monotone)
import Components.Recharts.LineChart (lineChart)
import Components.Recharts.ResponsiveContainer (pixels, responsiveContainer)
import Elmish (ReactElement)
import Elmish.HTML.Styled as H

-- POC for charts
view :: ReactElement
view =
  H.div "row" 
  [ H.div "col-12 col-md-6 col-lg-4" $
      H.div "card" $
        H.div "card-body" $
          responsiveContainer { height: pixels 300.0 } $
            lineChart { data: [{ a: 1, b: 2 }, { a: 2, b: 3 }, { a: 1, b: 4 }, { a: 3, b: 4 }] } $
              line { dataKey: "a", type: monotone }
  , H.div "col-12 col-md-6 col-lg-4" $
      H.div "card" $
        H.div "card-body" $
          responsiveContainer { height: pixels 300.0 } $
            lineChart { data: [{ a: 1, b: 2 }, { a: 2, b: 3 }, { a: 1, b: 4 }, { a: 3, b: 4 }] } $
              line { dataKey: "a", type: monotone }
  , H.div "col-12 col-md-6 col-lg-4" $
      H.div "card" $
        H.div "card-body" $
          responsiveContainer { height: pixels 300.0 } $
            lineChart { data: [{ a: 1, b: 2 }, { a: 2, b: 3 }, { a: 1, b: 4 }, { a: 3, b: 4 }] } $
              line { dataKey: "a", type: monotone }
  ]
