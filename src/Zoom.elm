module Zoom exposing (..)

import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Svg as S
import Svg.Attributes as SA

import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Chart.Svg as CS
import Html exposing (Html, div)
import Html.Attributes exposing (style)

type alias Model =
  { center : CS.Point
  , dragging : Dragging
  , percentage : Float
  }


type Dragging
  = CouldStillBeClick CS.Point
  | ForSureDragging CS.Point
  | None


init : () -> (Model, Cmd Msg)
init _ =
  ( { center = { x = 0, y = 0 }
    , dragging = None
    , percentage = 100
    }, Cmd.none )


type Msg
  = OnMouseMove CS.Point
  | OnMouseDown CS.Point
  | OnMouseUp CS.Point CS.Point
  | OnMouseLeave
  | OnZoomIn
  | OnZoomOut
  | OnZoomReset


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    OnMouseDown offset ->
      ( { model | dragging = CouldStillBeClick offset }, Cmd.none )

    OnMouseMove offset ->
      case model.dragging of
        CouldStillBeClick prevOffset ->
          if prevOffset == offset then
            (model, Cmd.none)
          else
            ( { model | center = updateCenter model.center prevOffset offset
              , dragging = ForSureDragging offset
              }
            , Cmd.none
            )

        ForSureDragging prevOffset ->
          ( { model | center = updateCenter model.center prevOffset offset
            , dragging = ForSureDragging offset
            }
          , Cmd.none
          )

        None ->
          (model, Cmd.none)

    OnMouseUp offset coord ->
      case model.dragging of
        CouldStillBeClick prevOffset ->
          ( { model | center = coord, dragging = None }, Cmd.none )

        ForSureDragging prevOffset ->
          ( { model | center = updateCenter model.center prevOffset offset
            , dragging = None
            }
          , Cmd.none
          )

        None ->
          (model, Cmd.none)

    OnMouseLeave ->
      ( { model | dragging = None }, Cmd.none )

    OnZoomIn ->
      ( { model | percentage = model.percentage + 20 }, Cmd.none )

    OnZoomOut ->
      ( { model | percentage = max 1 (model.percentage - 20) }, Cmd.none )

    OnZoomReset ->
      ( { model | percentage = 100, center = { x = 0, y = 0 } }, Cmd.none )

updateCenter : CS.Point -> CS.Point -> CS.Point -> CS.Point
updateCenter center prevOffset offset =
  { x = center.x + (prevOffset.x - offset.x)
  , y = center.y + (prevOffset.y - offset.y)
  }


view : Model -> Html Msg
view model =
  div 
        [  style "position" "absolute"
        , style "top" "50%"
        , style "left" "50%"
        , style "width" "500px"
        , style "height" "500px"
        , style "transform" "translate(-50%, -50%)"]
    [C.chart
    [ 
    CA.height 300
    , CA.width 300
    , CA.range [ CA.zoom model.percentage, CA.centerAt model.center.x ]
    , CA.domain [ CA.zoom model.percentage, CA.centerAt model.center.y ]

    , CE.onMouseDown OnMouseDown CE.getOffset
    , CE.onMouseMove OnMouseMove CE.getOffset
    , CE.on "mouseup" (CE.map2 OnMouseUp CE.getOffset CE.getCoords)
    , CE.onMouseLeave OnMouseLeave

    , CA.htmlAttrs
        [ HA.style "user-select" "none"
        , HA.style "cursor" <|
            case model.dragging of
              CouldStillBeClick _ -> "grabbing"
              ForSureDragging _ -> "grabbing"
              None -> "grab"
        ]
    ]
    [ C.xLabels [ CA.withGrid, CA.amount 10, CA.ints, CA.fontSize 9 ]
    , C.yLabels [ CA.withGrid, CA.amount 10, CA.ints, CA.fontSize 9 ]
    , C.xTicks [ CA.amount 10, CA.ints ]
    , C.yTicks [ CA.amount 10, CA.ints ]

    , C.series .x
        [ C.scatter .y [ CA.opacity 0.2, CA.borderWidth 1 ]
            |> C.variation (\_ d -> [ CA.size (d.s * model.percentage / 100), CA.hideOverflow ])
        ]
        [ { x = -100, y = -100, s = 40 }
        , { x = -80, y = -30, s = 30 }
        , { x = -60, y = 80, s = 60 }
        , { x = -50, y = 50, s = 70 }
        , { x = 20, y = 80, s = 40 }
        , { x = 30, y = -20, s = 60 }
        , { x = 40, y = 50, s = 80 }
        , { x = 80, y = 20, s = 50 }
        , { x = 100, y = 100, s = 40 }
        ]

    , C.withPlane <| \p ->
        [ C.line [ CA.color CA.darkGray, CA.dashed [ 6, 6 ], CA.y1 (CA.middle p.y) ]
        , C.line [ CA.color CA.darkGray, CA.dashed [ 6, 6 ], CA.x1 (CA.middle p.x) ]
        ]

    , C.htmlAt .max .max 0 0
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
            [ H.text "⨯" ]
        ]
    ]]



meta =
  { category = "Interactivity"
  , categoryOrder = 5
  , name = "Zoom"
  , description = "Add zoom effect."
  , order = 20
  }