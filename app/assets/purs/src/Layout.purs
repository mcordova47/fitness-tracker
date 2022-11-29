module Layout where


import Elmish (ReactElement)
import Elmish.HTML.Styled as H
import Layout.Nav as Nav

view :: Nav.Props -> ReactElement -> ReactElement
view navProps body =
  H.div "pt-3 px-3 h-100 d-flex flex-column"
  [ Nav.view navProps
  , H.div "flex-grow-1" body
  ]
