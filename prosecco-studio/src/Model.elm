module Model exposing (Databases, FetchState(..), Flags, Model, Msg(..), initialModel,changeUrl)

import Bootstrap.Navbar as Navbar
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Database.Model as SingleDBModel
import Databases.Model as DBModel
import Http
import Json.Decode exposing (bool)
import Routing exposing (Page(..), urlToPage)
import Url exposing (Url)


type Msg
    = UrlChanged Url.Url
    | UrlRequested UrlRequest
    | NavMsg Navbar.State
    | FetchDatabases (Result Http.Error Databases)
    | DatabasesMsg DBModel.Msg
    | DatabaseMsg SingleDBModel.Msg


type alias Flags =
    {}


type alias Databases =
    { databases : List String }


type alias Id =
    Int


type FetchState
    = FetchLoading
    | FetchDone
    | FetchError String


type alias Model =
    { page : Page
    , flags : Flags
    , url : Url.Url
    , key : Key
    , navState : Navbar.State
    , databasesState : DBModel.Model
    , loading : FetchState
    , dbState : SingleDBModel.Model
    }


initialModel : Flags -> Url.Url -> Key -> Navbar.State -> FetchState -> Model
initialModel flags url key navState fetch =
    let
        model =
            Model (urlToPage url) flags url key navState DBModel.initialModel fetch (SingleDBModel.initialModel "")

        ( newModel, cmd ) =
            changeUrl url model
    in
    newModel


changeUrl : Url -> Model -> ( Model, Cmd Msg )
changeUrl url model =
    let
        page =
            urlToPage url

        dbState =
            model.dbState
    in
    case page of
        DatabasePage s ->
            ( { model | page = page, dbState = { dbState | database = s } }, Cmd.none )

        _ ->
            ( { model | page = page }, Cmd.none )
