-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/effects/http.html


module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import RemoteData exposing (..)


main =
    Html.program
        { init = init "cats"
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { topic : String
    , gifUrl : WebData String
    }


init : String -> ( Model, Cmd Msg )
init topic =
    ( Model topic Loading
    , getRandomGif topic
    )



-- UPDATE


type Msg
    = MorePlease
    | ImgResponse (WebData String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MorePlease ->
            ( { model | gifUrl = Loading }
            , getRandomGif model.topic
            )

        ImgResponse response ->
            ( { model | gifUrl = response }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    let
        x =
            Debug.log "model" model

        waitingGifUrl =
            "https://media.giphy.com/media/UxREcFThpSEqk/giphy.gif"

        gifUrl =
            case model.gifUrl of
                NotAsked ->
                    waitingGifUrl

                Loading ->
                    waitingGifUrl

                Failure err ->
                    waitingGifUrl

                Success url ->
                    url
    in
        div []
            [ h2 [] [ text model.topic ]
            , button [ onClick MorePlease ] [ text "More Please!" ]
            , br [] []
            , img [ src gifUrl ] []
            ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


getRandomGif : String -> Cmd Msg
getRandomGif topic =
    let
        url =
            "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
    in
        Http.get url decodeGifUrl
            |> RemoteData.sendRequest
            |> Cmd.map ImgResponse


decodeGifUrl : Decode.Decoder String
decodeGifUrl =
    Decode.at [ "data", "image_url" ] Decode.string
