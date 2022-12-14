module Pages.Workouts.Progress.Chart
  ( ChartType(..)
  , Props
  , view
  )
  where

import Prelude

import Components.Chart as Chart
import Components.Recharts.Types.DataKey (dataKeyFunction, dataKeyString)
import Data.Array ((!!))
import Data.Array as Array
import Data.Foldable (maximum)
import Data.JSDate (JSDate)
import Data.Maybe (fromMaybe)
import Elmish (ReactElement)

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
  Chart.view
    { data': props.data'
    , lines: case props.chartType of
        Weight ->
          maximum (Array.length <<< _.weights <$> props.data')
            # fromMaybe 0
            # (_ - 1)
            # Array.range 0
            <#> \index ->
              { dataKey: dataKeyFunction (_.weights >>> (_ !! index))
              , key: props.keyPrefix <> "-weight-" <> show index
              , name: "Set " <> show (index + 1) <> " Weight"
              }
        Volume ->
          [ { dataKey: dataKeyString "volume"
            , key: props.keyPrefix <> "-volume"
            , name: "Volume"
            }
          ]
    , minimal: props.minimal
    }
