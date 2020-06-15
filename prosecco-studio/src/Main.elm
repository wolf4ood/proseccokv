module Main exposing (..)

import Browser
import Init exposing (init)
import Model exposing (Flags, Model, Msg(..))
import Update exposing (update)
import View exposing (view)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }
