module Pages.WorkOut
  ( view
  )
  where

import Prelude

import Api as Api
import Components.ReactSelect.Select (select)
import Data.Maybe (Maybe(..))
import Data.Nullable as Nullable
import Data.Tuple.Nested ((/\))
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Elmish (ReactElement, mkEffectFn1)
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks

type Props =
  { muscleGroups :: Array { name :: String }
  , userId :: String
  }

data SessionState
  = Loading
  | Loaded (Maybe Api.Session)

view :: Props -> ReactElement
view { muscleGroups, userId } = Hooks.component Hooks.do
  session /\ setSession <- Hooks.useState Loading

  Hooks.useEffect do
    s <- Api.todaysSession userId
    liftEffect $ setSession $ Loaded s

  Hooks.pure $
    case session of
      Loading -> H.empty
      Loaded (Just s) -> H.text $ "Muscle Group: " <> s.muscleGroup.name
      Loaded Nothing ->
        H.div "h-100 d-flex align-items-center justify-content-center" $
          H.div ""
          [ H.label "form-label" "Which muscle group are you working out today?"
          -- TODO: Make this creatable
          , select
              { onChange: mkEffectFn1 \mg -> launchAff_ do
                  s <- Api.saveSession { muscleGroup: mg.value, userId }
                  liftEffect $ setSession $ Loaded s
              , options: muscleGroups <#> \{ name } -> { label: name, value: name }
              , placeholder: "Select muscle group"
              , defaultValue: Nullable.null
              }
          ]
