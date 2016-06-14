module RegressionSummary exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

import RunTypeSummary exposing (..)

view props =
  div
    [ class "all-summaries" ]
    [
      div
        [ class "summary-container" ]
        [ (RunTypeSummary.view props.compileSummary) ]
    , div
        [ class "summary-container" ]
        [ (RunTypeSummary.view props.lintSummary) ]
    , div
        [ class "summary-container" ]
        [ (RunTypeSummary.view props.simSummary) ]
    ]
