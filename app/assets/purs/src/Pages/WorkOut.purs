module Pages.WorkOut
  ( view
  )
  where

import Prelude

import Api as Api
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Elmish (ReactElement, (<?|))
import Elmish.Foreign (readForeign)
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks

type Props =
  { userId :: String
  }

view :: Props -> ReactElement
view { userId } = Hooks.component Hooks.do
  session /\ setSession <- Hooks.useState Nothing
  muscleGroup /\ setMuscleGroup <- Hooks.useState ""

  Hooks.useEffect do
    s <- Api.todaysSession userId
    liftEffect $ setSession s

  Hooks.pure $
    case session of
      Just s -> H.text $ "Muscle Group: " <> s.muscleGroup
      Nothing ->
        H.div "h-100 d-flex align-items-center justify-content-center" $
          H.div "text-center"
          [ H.label_ "form-label"
              { htmlFor: "muscle-group-input" }
              "Which muscle group are you working out today?"
          , H.input_ "form-control"
              { id: "muscle-group-input"
              , value: muscleGroup
              , onChange: setMuscleGroup <?| \event -> do
                  e :: { target :: { value :: _ } } <- readForeign event
                  pure e.target.value
              }
          , H.button_ "btn btn-primary btn-block w-100 mt-3"
              { onClick: launchAff_ do
                  s <- Api.saveSession { muscleGroup, userId }
                  liftEffect $ setSession s
              }
              "Save"
          ]
