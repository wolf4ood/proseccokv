module Databases.View exposing (view)

import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Browser exposing (Document)
import Databases.Model exposing (Model, Msg(..))
import Html exposing (Html, br, button, div, h1, text)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Routing exposing (Page(..), pageToUrl)


view : Model -> List (Html Msg)
view model =
    [ h1 [] [ text "Home" ]
    , Grid.row [] <|
        List.map
            createItem
            model.databases
    ]


createItem : String -> Grid.Column Msg
createItem model =
    Grid.col []
        [ Card.config [ Card.outlinePrimary ]
            |> Card.headerH4 [] [ text model ]
            |> Card.block []
                [ Block.custom <|
                    Button.linkButton
                        [ Button.primary, Button.attrs [ href (pageToUrl <| DatabasePage model) ] ]
                        [ text "Open" ]
                ]
            |> Card.view
        ]
