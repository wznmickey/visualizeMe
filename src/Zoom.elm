module Zoom exposing (..)

import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Chart.Svg as CS
import Csv.Decode as Decode exposing (Decoder, column, float, into, pipeline, string)
import File exposing (File)
import File.Select as Select
import Html as H exposing (Html, div)
import Html.Attributes as HA exposing (style)
import Html.Events as HE
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
        sorted =
            List.sortBy .x points

        pareto =
            List.foldl
                (\p acc ->
                    if List.isEmpty acc || 
                       case List.head acc of
                           Just headPoint -> headPoint.y < p.y
                           Nothing -> True then
                        p :: acc

                    else
                        acc
                )
                []
                sorted
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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


updateCenter : CS.Point -> CS.Point -> CS.Point -> CS.Point
updateCenter center prevOffset offset =
    { x = center.x + (prevOffset.x - offset.x)
    , y = center.y + (prevOffset.y - offset.y)
    }


view : Model -> Html Msg
view model =
    div
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
                [ S.text "Process Size in nanometers" ]
            , C.labelAt .min
                CA.middle
                [ CA.moveLeft 18, CA.rotate 90 ]
                [ S.text "Thermal Design Power in Watts" ]
            , C.series .x
                [ C.scatter .y [ CA.opacity 0.2, CA.borderWidth 1 ]
                    |> C.variation (\_ d -> [ CA.size (d.s * model.percentage / 100 / 10), CA.hideOverflow ])
                ]
                model.data
            , C.series .x
            [ C.interpolated .y [ CA.monotone ] []
            ]
                (getPareto model.data)
            , C.eachDot <|
                \p dot ->
                    [ C.label
                        [ CA.moveDown 4, CA.color (CI.getColor dot), CA.fontSize 5 ]
                        [ S.text (CI.getData dot).w ]
                        (CI.getCenter p dot)
                    ]
            

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
                , H.button [ HE.onClick FileRequested ] [ H.text "Load CSV" ]
                ]
            ]
        ]


meta =
    { category = "Interactivity"
    , categoryOrder = 5
    , name = "Zoom"
    , description = "Add zoom effect."
    , order = 20
    }
