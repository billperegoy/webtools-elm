module RunTypeSummary exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import RegressionData exposing (..)

type alias Model =
  { label : String
  , result : SingleResult
  }

init : String -> SingleResult -> Model
init label result =
  Model label result
 
type Msg
  = NoOp
  | Update SingleResult

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    Update result ->
      {model | result = result} ! [] 

view : Model -> Html Msg
view model =
  div 
    [ class "run-type-summary" ]
    [
      div
        [ class "summary-label" ]
        [ text model.label ]
    , div 
        [ class "summary-results" ]
        [
          div
            [ class "summary-total" ]
            [ text ("total: " ++ toString model.result.total) ]
        , div
            [ class "summary-complete" ]
            [ text ("complete: " ++ toString model.result.complete) ]
        , div
            [ class "summary-failed" ]
            [ text ("failed: " ++ toString model.result.failed) ]
      ]
    ]

