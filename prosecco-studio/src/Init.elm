module Init exposing (..)

import Browser.Navigation exposing (Key)
import Model exposing (Flags, Model, Msg, Databases,FetchState(..), initialModel)
import Url
import Model exposing (Msg(..))
import Bootstrap.Navbar as Navbar
import Http
import Json.Decode as JD exposing (Decoder, field, string, list)


init : Flags -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key =

    let
        ( navState, navCmd ) =
            Navbar.initialState NavMsg  
        dbReq = getDatabasesList    
    in


    ( initialModel flags url key navState FetchLoading, Cmd.batch [navCmd, dbReq ] )



getDatabasesList : Cmd Msg
getDatabasesList =
  Http.get
    { url = "http://localhost:8080/databases"
    , expect =  Http.expectJson FetchDatabases databaseDecoder
    }



databaseDecoder : Decoder Databases 
databaseDecoder = 
    JD.map Databases 
        (field "databases" (JD.list JD.string))



