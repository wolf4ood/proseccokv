module Databases.Model exposing (Model, Msg(..), initialModel)


type alias Model =
    { databases: List String }


type Msg
    = Add String
    | Remove String
    | AddAll (List String)


initialModel : Model
initialModel =
    Model []
