module Main exposing (..)

import Browser
import View exposing (..)


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
