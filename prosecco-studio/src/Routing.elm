module Routing exposing (Page(..), pageToUrl, urlToPage)

import Url
import Url.Parser as UrlParser exposing ((</>), Parser, s, string)


type Page
    = Homepage
    | DatabasePage String
    | NotFound


pageToUrl : Page -> String
pageToUrl page =
    case page of
        Homepage ->
            "/"

        DatabasePage s ->
            "/database/" ++ s

        NotFound ->
            "/not-found"


urlToPage : Url.Url -> Page
urlToPage url =
    url
        |> UrlParser.parse urlParser
        |> Maybe.withDefault NotFound


urlParser : Parser (Page -> a) a
urlParser =
    UrlParser.oneOf
        [ UrlParser.map Homepage UrlParser.top
        , UrlParser.map DatabasePage (s "database" </> string)
        ]
