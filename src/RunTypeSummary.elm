module RunTypeSummary exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import RegressionData exposing (..)

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


view : RunTypeSummaryData -> Html a
view props =
  div 
    [ class "run-type-summary" ]
    [
      div
        [ class "summary-label" ]
        [ text props.label ]
    , div 
        [ class "summary-results pass-color" ]
        [
          div
            (totalClass props.result)
            [ text ("total: " ++ toString props.result.total) ]
        , div
            (completeClass props.result)
            [ text ("complete: " ++ toString props.result.complete) ]
        , div
            (failedClass props.result)
            [ text ("failed: " ++ toString props.result.failed) ]
      ]
    ]

