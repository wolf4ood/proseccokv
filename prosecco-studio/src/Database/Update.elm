module Database.Update exposing (update)

import Browser exposing (UrlRequest(..))
import Database.Model exposing (Model, Msg(..))
import Http


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Current s ->
            ( { model | database = s }, Cmd.none )

        FetchKey ->
            ( model, getKey model )

        PutKey ->
            ( model, putKey model )

        ChangePutKey s ->
            ( { model | putKey = s }, Cmd.none )

        ChangeGetKey s ->
            ( { model | getKey = s }, Cmd.none )

        FetchedKey r ->
            case r of
                Result.Ok data ->
                    ( { model | getValue = data }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ChangePutValue s ->
            ( { model | putValue = s }, Cmd.none )

        ChangedKey r ->
            ( model, Cmd.none )


getKey : Model -> Cmd Msg
getKey model =
    Http.get
        { url = "http://localhost:8080/databases/" ++ model.database ++ "/" ++ model.getKey
        , expect = Http.expectString FetchedKey
        }


putKey : Model -> Cmd Msg
putKey model =
    Http.request
        { body = Http.stringBody "application/json" model.putValue
        , expect = Http.expectString ChangedKey
        , headers = []
        , method = "PUT"
        , timeout = Nothing
        , tracker = Nothing
        , url = "http://localhost:8080/databases/" ++ model.database ++ "/" ++ model.putKey
        }
