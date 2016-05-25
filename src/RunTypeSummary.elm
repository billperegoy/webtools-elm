module RunTypeSummary exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import RegressionData exposing (..)

type alias Model =
  { label : String
  , total : Int
  , complete : Int
  , failed : Int
  }

init : String -> Int -> Int -> Int -> Model
init label total complete failed =
  Model label total complete failed
 
type Msg
  = NoOp
  | Update Int Int Int

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    Update total complete failed ->
      {model | total = total, complete = complete, failed = failed} ! [] 

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
            [ text ("total: " ++ toString model.total) ]
        , div
            [ class "summary-complete" ]
            [ text ("complete: " ++ toString model.complete) ]
        , div
            [ class "summary-failed" ]
            [ text ("failed: " ++ toString model.failed) ]
      ]
    ]

