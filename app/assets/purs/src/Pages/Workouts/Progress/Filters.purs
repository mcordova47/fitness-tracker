module Pages.Workouts.Progress.Filters
  ( Props
  , view
  )
  where

import Prelude

import Components.ButtonGroup as ButtonGroup
import Components.Dropdown (dropdown)
import Data.Maybe (Maybe(..))
import Elmish (ReactElement, Dispatch)
import Elmish.HTML.Styled as H
import Types.Workouts.MuscleGroup (MuscleGroup)
import Utils.Html ((&.>))

type Props =
  { muscleGroup :: Maybe Int
  , muscleGroups :: Array MuscleGroup
  , setMuscleGroup :: Dispatch (Maybe Int)
  }

view :: Props -> ReactElement
view props = H.div ""
  [ H.div "hidden md:inline-block" $
      muscleGroupFilter { vertical: false }
  , dropdown "inline-block md:hidden"
      { toggleClass: "px-3 pt-2 pb-1 bg-slate-200 dark:bg-slate-800 rounded-md relative"
      , toggleContent:
          H.span "fa-solid fa-sliders" $
            props.muscleGroup &.> \_ ->
              H.span_ "absolute top-0 left-full -translate-y-1/2 -translate-x-1/2 rounded-full text-xs text-white bg-cyan-600 h-4 w-4"
                { style: H.css { fontSize: "0.5rem" }
                }
                "1"
      } $
      H.div "px-3 pt-2 pb-3"
      [ H.div "text-slate-500 dark:text-white mb-2" "Muscle groups"
      , muscleGroupFilter { vertical: true }
      ]
  ]
  where
    muscleGroupFilter { vertical } =
      ButtonGroup.view
        { onClick: \id -> props.setMuscleGroup
            if props.muscleGroup == Just id then
              Nothing
            else
              Just id
        , options: props.muscleGroups <#> \{ id, name } -> { label: name, value: id }
        , value: props.muscleGroup
        , vertical
        }
