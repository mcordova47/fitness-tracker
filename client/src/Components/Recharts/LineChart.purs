module Components.Recharts.LineChart
  ( lineChart
  )
  where

import Elmish (ReactElement, createElement)
import Elmish.Foreign (class CanPassToJavaScript)
import Elmish.React (class ReactChildren)
import Elmish.React.Import (ImportedReactComponent)

type LineChartProps d =
  { data :: Array ( | d )
  }

lineChart :: forall d c. CanPassToJavaScript ( | d ) => ReactChildren c => LineChartProps d -> c -> ReactElement
lineChart = createElement lineChart_

foreign import lineChart_ :: ImportedReactComponent
