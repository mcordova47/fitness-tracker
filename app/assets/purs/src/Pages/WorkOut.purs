module Pages.WorkOut
  ( view
  )
  where

import Prelude

import Api as Api
import Components.ReactSelect.Select (select)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Data.Nullable (toNullable)
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Elmish (ReactElement, (<|))
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks

type Props =
  { muscleGroups :: Array { name :: String }
  , userId :: String
  }

view :: Props -> ReactElement
view { muscleGroups, userId } = Hooks.component Hooks.do
  session /\ setSession <- Hooks.useState Nothing
  muscleGroup /\ setMuscleGroup <- Hooks.useState Nothing

  Hooks.useEffect do
    s <- Api.todaysSession userId
    liftEffect $ setSession s

  Hooks.useEffect' muscleGroup \mg ->
    for_ mg \mg' -> do
      s <- Api.saveSession { muscleGroup: mg'.value, userId }
      liftEffect $ setSession s

  Hooks.pure $
    case session of
      Just s -> H.text $ "Muscle Group: " <> s.muscleGroup.name
      Nothing ->
        H.div "h-100 d-flex align-items-center justify-content-center" $
          H.div ""
          [ H.label "form-label" "Which muscle group are you working out today?"
          -- TODO: Make this creatable
          , select
              { onChange: (setMuscleGroup <<< Just) <| identity
              , options: muscleGroups <#> \{ name } -> { label: name, value: name }
              , placeholder: "Select muscle group"
              , value: toNullable muscleGroup
              }
          ]
