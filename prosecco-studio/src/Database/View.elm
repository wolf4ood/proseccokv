module Database.View exposing (view)

import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Grid as Grid
import Char exposing (toUpper)
import Database.Model exposing (Model, Msg(..))
import Html exposing (Html, h1, label, text)
import Html.Attributes exposing (disabled, for)
import Html.Events exposing (custom)
import Html.Events.Extra exposing (onChange)
import Json.Decode as Decode


view : Model -> List (Html Msg)
view model =
    [ Grid.container [] <|
        [ h1 [] [ text model.database ]
        , Grid.row
            []
            [ get_key model, put_key model ]
        ]
    ]


get_key : Model -> Grid.Column Msg
get_key model =
    Grid.col []
        [ Card.config [ Card.outlinePrimary ]
            |> Card.headerH4 [] [ text "Get Key" ]
            |> Card.block []
                [ Block.custom <|
                    genericForm
                        "get"
                        model.getValue
                        FetchKey
                        Nothing
                        ChangeGetKey
                ]
            |> Card.view
        ]


put_key : Model -> Grid.Column Msg
put_key model =
    Grid.col []
        [ Card.config [ Card.outlinePrimary ]
            |> Card.headerH4 [] [ text "Put Key" ]
            |> Card.block []
                [ Block.custom <|
                    genericForm
                        "put"
                        model.putValue
                        PutKey
                        (Just ChangePutValue)
                        ChangePutKey
                ]
            |> Card.view
        ]


genericForm : String -> String -> Msg -> Maybe (String -> Msg) -> (String -> Msg) -> Html Msg
genericForm op value onSubmission onTextChange msg =
    let
        inputId =
            op ++ "inputkey"

        textId =
            op ++ "areakey"
    in
    Form.form
        [ onSubmitCustom onSubmission ]
        [ Form.group []
            [ Form.label [ for inputId ] [ text "Key" ]
            , Input.text [ Input.id inputId, Input.attrs [ onChange msg ] ]
            ]
        , Form.group []
            [ label [ for textId ] [ text "My textarea" ]
            , Textarea.textarea
                [ Textarea.id textId
                , Textarea.rows 3
                , Textarea.value value
                , Textarea.attrs
                    ([] ++ maybeOnChange onTextChange)
                ]
            ]
        , Button.button [ Button.primary ] [ text <| String.toUpper op ]
        ]


maybeOnChange : Maybe (String -> msg) -> List (Html.Attribute msg)
maybeOnChange msg =
    case msg of
        Just m ->
            [ onChange m ]

        Nothing ->
            [ disabled True]


onSubmitCustom : msg -> Html.Attribute msg
onSubmitCustom msg =
    custom "submit"
        (Decode.succeed
            { message = msg
            , stopPropagation = True
            , preventDefault = True
            }
        )
