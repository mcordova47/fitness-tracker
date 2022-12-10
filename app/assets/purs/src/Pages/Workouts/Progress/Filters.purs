module Pages.Workouts.Progress.Filters
  ( Props
  , view
  )
  where

import Prelude

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
view props = H.fragment
  [ H.div "d-none d-md-inline-block" $
      muscleGroupFilter "btn-group"
  , dropdown "d-inline-block d-md-none"
      { toggleClass: "btn btn-light"
      , toggleContent:
          H.span "fa-solid fa-sliders" $
            props.muscleGroup &.> \_ ->
              H.span_ "position-absolute top-0 start-100 translate-middle badge rounded-pill bg-primary"
                { style: H.css { fontSize: "0.5rem" }
                } $
                [ H.text "1"
                , H.span "visually-hidden" " applied filters"
                ]
      } $
      H.div "px-3 pt-1 pb-2"
      [ H.div "text-muted" "Muscle groups"
      , muscleGroupFilter "btn-group-vertical btn-group-sm w-100 mt-2"
      ]
  ]
  where
    muscleGroupFilter className =
      H.div className $
        props.muscleGroups <#> \{ id, name } ->
          H.button_ ("btn w-100 btn-" <> if props.muscleGroup == Just id then "primary" else "outline-primary")
            { onClick: props.setMuscleGroup
                if props.muscleGroup == Just id then
                  Nothing
                else
                  Just id
            }
            name
