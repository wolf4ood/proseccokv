module Databases.Update exposing (update)

import Browser exposing (UrlRequest(..))
import Databases.Model exposing (Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Add a ->
            ( { model | databases = model.databases ++ [ a ] }, Cmd.none )

        Remove a ->
            ( { model | databases = List.filter (\x -> x /= a) model.databases }, Cmd.none )

        AddAll a ->
            ( { model | databases = model.databases ++ a }, Cmd.none )
