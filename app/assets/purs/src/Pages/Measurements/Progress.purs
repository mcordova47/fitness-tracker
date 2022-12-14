module Pages.Measurements.Progress
  ( Props
  , view
  )
  where

import Prelude

import Api.Measurements as Api
import Components.Chart as Chart
import Components.Recharts.ResponsiveContainer (pixels, responsiveContainer)
import Components.Recharts.Types.DataKey (dataKeyString)
import Data.Array (foldl)
import Data.JSDate (JSDate)
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Elmish (ReactElement)
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks
import Types.Measurements.Measurement (Measurement)

type Props =
  { userId :: String
  }

view :: Props -> ReactElement
view { userId } = Hooks.component Hooks.do
  measurements /\ setMeasurements <- Hooks.useState Nothing

  Hooks.useEffect do
    m <- Api.measurements userId
    liftEffect $ setMeasurements $ measurementsByBodyPart <$> m

  Hooks.pure $
    H.div "mt-3"
      case measurements of
        Nothing -> H.empty
        Just measurements' ->
          H.div "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4" $
            measurements'
              # (Map.toUnfoldable :: _ -> Array _)
              <#> \(bodyPart /\ ms) ->
                H.div "border border-slate-200 dark:border-slate-700 dark:bg-slate-700 rounded-lg" $
                [ H.h6 "text-slate-500 text-sm border-b border-slate-200 dark:text-white dark:bg-slate-800 dark:border-none p-4 uppercase rounded-t-lg"
                    bodyPart
                , H.div "p-4" $
                    responsiveContainer { height: pixels 300.0 } $
                      Chart.view
                        { data': ms
                        , lines:
                            [ { dataKey: dataKeyString "value"
                              , key: bodyPart
                              , name: "Measurement"
                              }
                            ]
                        , minimal: true
                        }
                ]

measurementsByBodyPart :: Array Measurement -> Map String (Array { value :: Number, date :: JSDate })
measurementsByBodyPart = foldl insertMeasurement Map.empty
  where
    insertMeasurement bps { value, date, bodyPart } =
      Map.insertWith (<>) bodyPart.name [{ value, date }] bps
