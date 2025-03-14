module Main exposing (..)

import Zoom exposing (..)
import Browser
main =
  Browser.element
      { init = init
      , view = view
      , update = update
      , subscriptions = \_ -> Sub.none
      }