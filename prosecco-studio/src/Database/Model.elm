module Database.Model exposing (Model, Msg(..), initialModel)

import Http


type alias Model =
    { database : String, getKey : String, getValue : String, putKey : String, putValue : String }


type Msg
    = Current String
    | FetchKey
    | PutKey
    | ChangePutKey String
    | ChangePutValue String
    | ChangeGetKey String
    | FetchedKey (Result Http.Error String)
    | ChangedKey (Result Http.Error String)


initialModel : String -> Model
initialModel s =
    { database = s, getKey = "", getValue = "", putKey = "", putValue = "" }
