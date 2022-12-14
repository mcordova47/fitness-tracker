module Components.Chart where

import Prelude

import Components.Recharts.CartesianGrid (cartesianGrid)
import Components.Recharts.Line (line, linear, monotone)
import Components.Recharts.LineChart (lineChart)
import Components.Recharts.Tick (tick)
import Components.Recharts.Tooltip (labelFormatter, tooltip)
import Components.Recharts.Types.DataKey (DataKey, dataKeyString)
import Components.Recharts.XAxis (tickFormatter, xAxis)
import Components.Recharts.YAxis (yAxis)
import Data.Array ((!!))
import Data.Array as Array
import Data.JSDate as JSDate
import Data.Maybe (fromMaybe)
import Elmish (ReactElement)
import Elmish.Foreign (class CanPassToJavaScript)
import Elmish.HTML.Styled as H
import Utils.Html ((&>))

type Props d =
  { data' :: Array d
  , lines :: Array { dataKey :: DataKey, key :: String, name :: String }
  , minimal :: Boolean
  }

view :: ∀ d. CanPassToJavaScript d => Props d -> ReactElement
view props =
  lineChart { data: props.data' }
  [ H.fragment $ props.lines # Array.mapWithIndex \index { dataKey, key, name } ->
      line
        { dataKey
        , key
        , name
        , stroke: color index
        , strokeWidth: if props.minimal then 1.5 else 2.0
        , type: if props.minimal then monotone else linear
        }
  , not props.minimal &> H.fragment
      [ xAxis
          { dataKey: dataKeyString "date"
          , tick: tick {}
          , tickFormatter: tickFormatter JSDate.toDateString
          }
      , yAxis { tick: tick {} }
      , cartesianGrid { strokeDasharray: "3 3" }
      , tooltip
          { contentStyle: H.css { background: "rgb(30 41 59)" }
          , labelFormatter: labelFormatter JSDate.toDateString
          }
      ]
  ]

color :: Int -> String
color index = colors !! (index `mod` Array.length colors) # fromMaybe defaultColor
  where
    colors =
      [ defaultColor
      , "#EA4235"
      , "#FBBC05"
      , "#33A854"
      , "#FF6D02"
      , "#46BDC6"
      , "#7BAAF7"
      , "#F07B72"
      , "#FCD050"
      ]

defaultColor :: String
defaultColor = "#4385F4"
