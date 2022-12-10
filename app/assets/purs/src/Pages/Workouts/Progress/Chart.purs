module Pages.Workouts.Progress.Chart
  ( ChartType(..)
  , Props
  , view
  )
  where

import Prelude

import Components.Recharts.CartesianGrid (cartesianGrid)
import Components.Recharts.Line (line, linear, monotone)
import Components.Recharts.LineChart (lineChart)
import Components.Recharts.Tooltip (tooltip)
import Components.Recharts.Types.DataKey (dataKeyFunction, dataKeyString)
import Components.Recharts.XAxis (tickFormatter, xAxis)
import Components.Recharts.YAxis (yAxis)
import Data.Array ((!!))
import Data.Array as Array
import Data.Foldable (maximum)
import Data.JSDate (JSDate)
import Data.JSDate as JSDate
import Data.Maybe (fromMaybe)
import Elmish (ReactElement)
import Elmish.HTML.Styled as H
import Utils.Html ((&>))

type Props =
  { chartType :: ChartType
  , data' :: Array { date :: JSDate, weights :: Array Number, volume :: Number }
  , keyPrefix :: String
  , minimal :: Boolean
  }

data ChartType
  = Weight
  | Volume
derive instance Eq ChartType

view :: Props -> ReactElement
view props =
  lineChart { data: props.data' }
    [ case props.chartType of
        Weight -> H.fragment $
          maximum (Array.length <<< _.weights <$> props.data')
            # fromMaybe 0
            # (_ - 1)
            # Array.range 0
            <#> \index ->
              line
                { dataKey: dataKeyFunction (_.weights >>> (_ !! index))
                , key: props.keyPrefix <> "-weight-" <> show index
                , name: "Set " <> show (index + 1) <> " Weight"
                , stroke: color index
                , strokeWidth: if props.minimal then 1.5 else 2.0
                , type: if props.minimal then monotone else linear
                }
        Volume ->
          line
            { dataKey: dataKeyString "volume"
            , key: props.keyPrefix <> "-volume"
            , name: "Volume"
            , stroke: defaultColor
            , strokeWidth: if props.minimal then 1.5 else 2.0
            , type: if props.minimal then monotone else linear
            }
    , not props.minimal &> H.fragment
        [ xAxis
            { dataKey: dataKeyString "date"
            , tickFormatter: tickFormatter JSDate.toDateString
            }
        , yAxis {}
        , cartesianGrid { strokeDasharray: "3 3" }
        , tooltip {}
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
