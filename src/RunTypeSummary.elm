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

updateNoCmd : Msg -> Model  -> Model
updateNoCmd msg model =
  fst(update msg model)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    Update result ->
      {model | result = result} ! [] 

totalClass : SingleResult -> List (Attribute a) 
totalClass result =
  if result.total == result.complete then
    [ class "summary-total pass-color" ]
  else
    [ class "summary-total run-color" ]

failedClass : SingleResult -> List (Attribute a) 
failedClass result =
  if result.failed == 0 then
    [ class "summary-complete pass-color" ]
  else
    [ class "summary-complete fail-color" ]

completeClass : SingleResult -> List (Attribute a) 
completeClass result =
  if result.complete == result.total then
    [ class "summary-failed pass-color" ]
  else
    [ class "summary-failed run-color" ]


view : Model -> Html Msg
view model =
  div 
    [ class "run-type-summary" ]
    [
      div
        [ class "summary-label" ]
        [ text model.label ]
    , div 
        [ class "summary-results pass-color" ]
        [
          div
            (totalClass model.result)
            [ text ("total: " ++ toString model.result.total) ]
        , div
            (completeClass model.result)
            [ text ("complete: " ++ toString model.result.complete) ]
        , div
            (failedClass model.result)
            [ text ("failed: " ++ toString model.result.failed) ]
      ]
    ]

