module View exposing (..)

import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Chart.Svg as CS
import Csv.Decode as Decode exposing (Decoder, column, float, into, pipeline, string)
import File exposing (File)
import File.Select as Select
import Html as H exposing (Html, button, div, input, text)
import Html.Attributes as HA exposing (placeholder, style, value)
import Html.Events as HE exposing (onClick, onInput)
import Html.Events.Extra.Wheel as Wheel
import Http
import Svg as S
import Svg.Attributes as SA
import Task


type alias Point =
    { x : Float
    , y : Float
    , s : Float
    , w : String
    }


getPareto : List Point -> List Point
getPareto points =
    let
        sortedx =
            List.sortBy .x points

        paretoy =
            List.foldl
                (\p acc ->
                    if
                        List.isEmpty acc
                            || (case List.head acc of
                                    Just headPoint ->
                                        headPoint.y < p.y

                                    Nothing ->
                                        True
                               )
                    then
                        p :: acc

                    else
                        acc
                )
                []
                sortedx

        -- Remove duplicates
        pareto =
            List.foldl
                (\p acc ->
                    if
                        List.isEmpty acc
                            || (case List.head acc of
                                    Just headPoint ->
                                        headPoint.x /= p.x

                                    Nothing ->
                                        True
                               )
                    then
                        p :: acc

                    else
                        acc
                )
                []
                paretoy
    in
    List.reverse pareto


decoder : Decoder Point
decoder =
    into Point
        |> pipeline (column 1 float)
        |> pipeline (column 2 float)
        |> pipeline (column 3 float)
        |> pipeline (column 0 string)


type alias Model =
    { center : CS.Point
    , dragging : Dragging
    , percentage : Float
    , data : List Point
    , showSize : Bool
    , showText : Bool
    , showPareto : Bool
    , textX : String
    , textY : String
    , url : String
    }


type Dragging
    = CouldStillBeClick CS.Point
    | ForSureDragging CS.Point
    | None


init : () -> ( Model, Cmd Msg )
init _ =
    ( { center = { x = 0, y = 0 }
      , dragging = None
      , percentage = 100
      , data =
            [ { x = 65, y = 45, s = 77, w = "AMD Athlon 64 3500+" }
            , { x = 14, y = 35, s = 192, w = "AMD Athlon 200GE" }
            , { x = 22, y = 80, s = 160, w = "Intel Xeon E5-2603 v2" }
            , { x = 45, y = 125, s = 258, w = "AMD Phenom II X4 980 BE" }
            , { x = 22, y = 95, s = 160, w = "\tIntel Xeon E5-2470 v2" }
            ]
      , showSize = True
      , showText = True
      , showPareto = False
      , textX = "Process Size in nanometers"
      , textY = "Thermal Design Power in Watts"
      , url = ""
      }
    , Cmd.none
    )


type Msg
    = OnMouseMove CS.Point
    | OnMouseDown CS.Point
    | OnMouseUp CS.Point CS.Point
    | OnMouseLeave
    | OnZoomIn
    | OnZoomOut
    | OnZoomReset
    | FileRequested
    | FileUpload File
    | FileLoad String
    | ToggleShowSize
    | ToggleShowText
    | ToggleShowPareto
    | OnWheelEvent Float
    | UpdateTextX String
    | UpdateTextY String
    | UpdateUrl String
    | LoadUrl
    | GotResponse (Result Http.Error String)


loadRemoteFile : String -> Cmd Msg
loadRemoteFile url =
    Http.get
        { url = url
        , expect = Http.expectString GotResponse
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateUrl newUrl ->
            ( { model | url = newUrl }, Cmd.none )

        LoadUrl ->
            if String.isEmpty model.url then
                ( model, Task.perform (\_ -> FileRequested) (Task.succeed ()) )

            else
                ( model, loadRemoteFile model.url )

        GotResponse result ->
            case result of
                Ok body ->
                    ( model, Task.perform FileLoad (Task.succeed body) )

                Err error ->
                    ( {model | url = Debug.toString error}, Cmd.none )

        OnMouseDown offset ->
            ( { model | dragging = CouldStillBeClick offset }, Cmd.none )

        OnMouseMove offset ->
            case model.dragging of
                CouldStillBeClick prevOffset ->
                    if prevOffset == offset then
                        ( model, Cmd.none )

                    else
                        ( { model
                            | center = updateCenter model.center prevOffset offset
                            , dragging = ForSureDragging offset
                          }
                        , Cmd.none
                        )

                ForSureDragging prevOffset ->
                    ( { model
                        | center = updateCenter model.center prevOffset offset
                        , dragging = ForSureDragging offset
                      }
                    , Cmd.none
                    )

                None ->
                    ( model, Cmd.none )

        OnMouseUp offset coord ->
            case model.dragging of
                CouldStillBeClick prevOffset ->
                    ( { model | center = coord, dragging = None }, Cmd.none )

                ForSureDragging prevOffset ->
                    ( { model
                        | center = updateCenter model.center prevOffset offset
                        , dragging = None
                      }
                    , Cmd.none
                    )

                None ->
                    ( model, Cmd.none )

        OnMouseLeave ->
            ( { model | dragging = None }, Cmd.none )

        OnZoomIn ->
            ( { model | percentage = model.percentage + 20 }, Cmd.none )

        OnZoomOut ->
            ( { model | percentage = max 1 (model.percentage - 20) }, Cmd.none )

        OnZoomReset ->
            ( { model | percentage = 100, center = { x = 0, y = 0 } }, Cmd.none )

        FileRequested ->
            ( model
            , Select.file [ "text/csv" ] FileUpload
            )

        FileUpload file ->
            ( model, Task.perform FileLoad (File.toString file) )

        FileLoad str ->
            ( { model
                | data =
                    case
                        Decode.decodeCsv Decode.NoFieldNames decoder str
                    of
                        Ok points ->
                            points

                        Err err ->
                            []
              }
            , Cmd.none
            )

        ToggleShowSize ->
            ( { model | showSize = not model.showSize }, Cmd.none )

        ToggleShowText ->
            ( { model | showText = not model.showText }, Cmd.none )

        ToggleShowPareto ->
            ( { model | showPareto = not model.showPareto }, Cmd.none )

        OnWheelEvent delta ->
            ( { model
                | percentage =
                    if delta > 0 then
                        model.percentage + 20

                    else
                        max 1 (model.percentage - 20)
              }
            , Cmd.none
            )

        UpdateTextX text ->
            ( { model | textX = text }, Cmd.none )

        UpdateTextY text ->
            ( { model | textY = text }, Cmd.none )


updateCenter : CS.Point -> CS.Point -> CS.Point -> CS.Point
updateCenter center prevOffset offset =
    { x = center.x + (prevOffset.x - offset.x)
    , y = center.y + (prevOffset.y - offset.y)
    }


view : Model -> Html Msg
view model =
    div []
        [ div
            [ style "position" "absolute" ]
            [ div []
                [ H.label []
                    [ H.input [ HA.type_ "checkbox", HA.checked model.showSize, HE.onClick ToggleShowSize ] []
                    , H.text " Show size"
                    ]
                , H.label []
                    [ H.input [ HA.type_ "checkbox", HA.checked model.showText, HE.onClick ToggleShowText ] []
                    , H.text " Show text"
                    ]
                , H.label []
                    [ H.input [ HA.type_ "checkbox", HA.checked model.showPareto, HE.onClick ToggleShowPareto ] []
                    , H.text " Show pareto line"
                    ]

                    , H.input
            [ placeholder "Input URL"
            , value model.url
            , onInput UpdateUrl
            ]
            []
        , H.button [ onClick LoadUrl ] [ text "Load" ]
                ]
                
            , div []
                [ H.input
                    [ HA.value model.textX
                    , HE.onInput UpdateTextX
                    ]
                    []
                , H.input
                    [ HA.value model.textY
                    , HE.onInput UpdateTextY
                    ]
                    []
                ]
            ]
        , div
            [ style "width" "100vw", style "height" "100vh", style "overflow" "hidden", Wheel.onWheel chooseZoom ]
            []
        , div
            [ style "position" "absolute"
            , style "top" "calc(50vh - 40vh)"
            , style "left" "calc(50vw - 40vh)"
            , style "width" "80vh"
            , style "height" "80vh"
            ]
            [ C.chart
                [ CA.height 300
                , CA.width 300
                , CA.range [ CA.highest 300 CA.orHigher, CA.zoom model.percentage, CA.centerAt model.center.x ]
                , CA.domain [ CA.highest 300 CA.orHigher, CA.zoom model.percentage, CA.centerAt model.center.y ]
                , CE.onMouseDown OnMouseDown CE.getOffset
                , CE.onMouseMove OnMouseMove CE.getOffset
                , CE.on "mouseup" (CE.map2 OnMouseUp CE.getOffset CE.getCoords)
                , CE.onMouseLeave OnMouseLeave
                , CA.htmlAttrs
                    [ HA.style "user-select" "none"
                    , HA.style "cursor" <|
                        case model.dragging of
                            CouldStillBeClick _ ->
                                "grabbing"

                            ForSureDragging _ ->
                                "grabbing"

                            None ->
                                "grab"
                    ]
                ]
                [ C.xLabels [ CA.withGrid, CA.amount 5, CA.ints, CA.fontSize 9 ]
                , C.yLabels [ CA.withGrid, CA.amount 5, CA.ints, CA.fontSize 9 ]
                , C.xTicks [ CA.amount 10, CA.ints ]
                , C.yTicks [ CA.amount 10, CA.ints ]
                , C.labelAt CA.middle
                    .min
                    [ CA.moveDown 18 ]
                    [ S.text model.textX ]
                , C.labelAt .min
                    CA.middle
                    [ CA.moveLeft 18, CA.rotate 90 ]
                    [ S.text model.textY ]
                , C.series .x
                    [ C.scatter .y [ CA.opacity 0.2, CA.borderWidth 1 ]
                        |> C.variation
                            (\_ d ->
                                [ CA.size
                                    (if model.showSize then
                                        d.s * model.percentage / 100 / 10

                                     else
                                        1
                                    )
                                , CA.hideOverflow
                                ]
                            )
                    ]
                    model.data
                , if model.showPareto then
                    C.series .x
                        [ C.interpolated .y [ CA.monotone ] []
                        ]
                        (getPareto model.data)

                  else
                    C.series .x
                        [ C.interpolated .y [ CA.monotone ] []
                        ]
                        []
                , if model.showText then
                    C.eachDot <|
                        \p dot ->
                            [ C.label
                                [ CA.moveDown 4, CA.color (CI.getColor dot), CA.fontSize 5 ]
                                [ S.text (CI.getData dot).w ]
                                (CI.getCenter p dot)
                            ]

                  else
                    C.eachDot <|
                        \_ _ ->
                            []

                -- C.eachDot <|
                --     \p dot ->
                --         [ C.label
                --             [ CA.moveDown 4, CA.color (CI.getColor dot), CA.fontSize 5 ]
                --             [ S.text (CI.getData dot).w ]
                --             (CI.getCenter p dot)
                --         ]
                -- , C.withPlane <|
                --     \p ->
                --         [ C.line [ CA.color CA.darkGray, CA.dashed [ 6, 6 ], CA.y1 (CA.middle p.y) ]
                --         , C.line [ CA.color CA.darkGray, CA.dashed [ 6, 6 ], CA.x1 (CA.middle p.x) ]
                --         ]
                , C.htmlAt .max
                    .max
                    0
                    0
                    [ HA.style "transform" "translateX(-100%)" ]
                    [ H.span
                        [ HA.style "margin-right" "5px" ]
                        [ H.text (String.fromFloat model.percentage ++ "%") ]
                    , H.button
                        [ HE.onClick OnZoomIn
                        , HA.style "margin-right" "5px"
                        ]
                        [ H.text "+" ]
                    , H.button
                        [ HE.onClick OnZoomOut
                        , HA.style "margin-right" "5px"
                        ]
                        [ H.text "-" ]
                    , H.button
                        [ HE.onClick OnZoomReset ]
                        [ H.text "Reset" ]
                    
                    ]
                ]
            ]
        ]


chooseZoom : Wheel.Event -> Msg
chooseZoom wheelEvent =
    case wheelEvent of
        event ->
            OnWheelEvent event.deltaY


meta =
    { category = "Interactivity"
    , categoryOrder = 5
    , name = "Zoom"
    , description = "Add zoom effect."
    , order = 20
    }
