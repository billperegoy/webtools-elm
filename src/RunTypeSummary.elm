module RunTypeSummary exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias Model =
  { label : String
  , total : Int
  , running : Int
  , failed : Int
  }

init : String -> Int -> Int -> Int -> Model
init label total running failed =
  Model label total running failed
 
type Msg
  = NoOp
  | Update Int Int Int

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    Update total running failed ->
      {model | total = total, running = running, failed = failed} ! [] 

view : Model -> Html Msg
view model =
  div 
    []
    [
      div
        [ class "summary-label" ]
        [ text model.label ]
    , div
        [ class "summary-total" ]
        [ text (toString model.total) ]
    , div
        [ class "summary-running" ]
        [ text (toString model.running) ]
    , div
        [ class "summary-failed" ]
        [ text (toString model.failed) ]
    , button 
        [ onClick (Update 1 2 3) ] 
        [ text "push me" ]
    ]

