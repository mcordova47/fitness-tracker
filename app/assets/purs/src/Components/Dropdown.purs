module Components.Dropdown
  ( ContentArgs
  , dropdown
  , dropdown'
  )
  where

import Prelude

import Components.BrowserEvents (browserEvents)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Elmish (ReactElement, mkEffectFn1)
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks
import Unsafe.Coerce (unsafeCoerce)
import Utils.Html (htmlIf)
import Web.DOM.Node as Node
import Web.Event.Event as E
import Web.HTML.HTMLDivElement as Div

type Args = BaseArgs ()
type Args' = BaseArgs
  ( closeOnClick :: Boolean
  , content :: ContentArgs -> ReactElement
  )
type BaseArgs r =
  { toggleClass :: String
  , toggleContent :: ReactElement
  | r
  }

type ContentArgs =
  { visible :: Boolean
  , className :: String
  , closeDropdown :: Effect Unit
  }

dropdown :: String -> Args -> ReactElement -> ReactElement
dropdown className' args content =
  dropdown' className'
    { toggleClass: args.toggleClass
    , toggleContent: args.toggleContent
    , content: \{ className, visible } ->
        if visible then
          H.div className content
        else
          H.empty
    , closeOnClick: false
    }

dropdown' :: String -> Args' -> ReactElement
dropdown' className args = Hooks.component Hooks.do
  expanded /\ setExpanded <- Hooks.useState false
  ref /\ setRef <- Hooks.useRef

  Hooks.pure $
    H.div_ ("dropdown " <> className <> if expanded then " show" else "")
    { onClick: if args.closeOnClick && expanded then setExpanded false else pure unit
    , ref: setRef
    }
    [ H.button_ args.toggleClass
        { onClick: setExpanded $ not expanded }
        args.toggleContent
    , args.content
        { visible: expanded
        , className: "dropdown-menu show"
        , closeDropdown: setExpanded false
        }
    , htmlIf expanded $
        browserEvents
        { mouseup: mkEffectFn1 \event ->
            unlessM (isWithinTreeOf (Div.toNode <$> ref) (eventTargetNode event)) $
              setExpanded false
        }
    ]
  where
    isWithinTreeOf Nothing _ = pure false
    isWithinTreeOf _ Nothing = pure false
    isWithinTreeOf (Just root) (Just nested) = do
      same <- Node.isEqualNode root nested
      if same then
        pure true
      else
        isWithinTreeOf (Just root) =<< Node.parentNode nested

    eventTargetNode event = (unsafeCoerce event :: E.Event) # E.target >>= Node.fromEventTarget
