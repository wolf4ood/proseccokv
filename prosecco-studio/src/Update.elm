module Update exposing (update)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Database.Update as DatabaseUpdate
import Databases.Model as DatabasesModel
import Databases.Update as DatabasesUpdate
import Model exposing (FetchState(..), Model, Msg(..), changeUrl)
import Platform.Cmd exposing (Cmd)
import Routing exposing (Page(..))
import Url exposing (toString)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged url ->
            changeUrl url model

        UrlRequested urlRequest ->
            let
                command =
                    case urlRequest of
                        Internal url ->
                            Nav.pushUrl model.key <| Url.toString url

                        External string ->
                            Nav.load string
            in
            ( model, command )

        NavMsg navS ->
            ( { model | navState = navS }, Cmd.none )

        FetchDatabases dbs ->
            case dbs of
                Result.Ok s ->
                    let
                        ( subModel, subMsg ) =
                            update (DatabasesMsg <| DatabasesModel.AddAll s.databases) model
                    in
                    ( { model | loading = FetchDone, databasesState = subModel.databasesState }, subMsg )

                Result.Err _ ->
                    ( { model | loading = FetchError "Error getting the databases list" }, Cmd.none )

        DatabasesMsg msg_ ->
            let
                ( subModel, subMsg ) =
                    DatabasesUpdate.update msg_ model.databasesState
            in
            ( { model | databasesState = subModel }, Cmd.map DatabasesMsg subMsg )

        DatabaseMsg msg_ ->
            let
                ( subModel, subMsg ) =
                    DatabaseUpdate.update msg_ model.dbState
            in
            ( { model | dbState = subModel }, Cmd.map DatabaseMsg subMsg )
