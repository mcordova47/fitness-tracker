module Components.Dropdown
  ( ContentArgs
  , dropdown
  , dropdown'
  )
  where

import Prelude

import Components.BrowserEvents (browserEvents)
import Control.Alternative (guard)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Elmish (ReactElement, (<?|), (<|))
import Elmish.HTML.Events as E
import Elmish.HTML.Styled as H
import Elmish.Hooks as Hooks
import Utils.Html ((&>))
import Web.DOM.Element as Element
import Web.DOM.Node as Node
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
    H.div_ (className <> " relative")
    { onClick: setExpanded <?| (guard (args.closeOnClick && expanded) *> Just false)
    , ref: setRef
    }
    [ H.button_ args.toggleClass
        { onClick: setExpanded <| not expanded }
        args.toggleContent
    , args.content
        { visible: expanded
        , className: "absolute left-0 z-10 mt-2 w-56 origin-top-left rounded-md bg-white dark:bg-slate-800 dark:border dark:border-slate-700 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
        , closeDropdown: setExpanded false
        }
    , expanded &>
        browserEvents
        { mouseup: E.handleEffect \(E.MouseEvent event) ->
            unlessM (isWithinTreeOf (Div.toNode <$> ref) $ Just $ Element.toNode event.target) $
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
