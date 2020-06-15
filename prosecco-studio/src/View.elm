module View exposing (view)

import Bootstrap.Grid as Grid
import Bootstrap.Navbar as Navbar
import Browser exposing (Document)
import Database.View
import Databases.View
import Html exposing (Html, a, div, nav, text)
import Html.Attributes exposing (href)
import Model exposing (FetchState(..), Model, Msg(..))
import Routing exposing (Page(..), pageToUrl)


view : Model -> Document Msg
view model =
    { title = "Homepage", body = [ doView model ] }


doView : Model -> Html Msg
doView model =
    nav []
        [ menu model
        , viewPage model
        ]


viewPage : Model -> Html Msg
viewPage model =
    Grid.container [] <|
        case model.loading of
            FetchLoading ->
                [ Html.text "Loading..." ]

            FetchDone ->
                case model.page of
                    Homepage ->
                        List.map (Html.map DatabasesMsg) <| Databases.View.view model.databasesState

                    DatabasePage s ->
                        List.map (Html.map DatabaseMsg) <| Database.View.view model.dbState

                    NotFound ->
                        List.singleton <| Html.text "not found"

            FetchError err ->
                [ Html.text err ]


menu : Model -> Html Msg
menu model =
    Navbar.config NavMsg
        |> Navbar.withAnimation
        |> Navbar.container
        |> Navbar.brand [ href (pageToUrl Homepage) ] [ text "ProseccoKV" ]
        |> Navbar.items
            [-- , Navbar.itemLink [ href "#modules" ] [ text "Modules" ]
            ]
        |> Navbar.view model.navState
