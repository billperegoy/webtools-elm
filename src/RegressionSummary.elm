module RegressionSummary exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

import RunTypeSummary exposing (..)

view props =
  div
    [ class "regression-summary" ]
    [
{- FIXME
      div
        []
        [ text ("Run Name: " ++ props.runName) ]
    , div
        []
        [ text ("Release Label: " ++ props.releaseLabel) ]
    , div
        []
        [ text ("Run Status: " ++ props.runStatus) ]
    , div
        []
        [ text "Progress Bar" ]
    , div
        []
        [ text ("Elapsed Time: " ++ toString props.elapsedTime) ]
    , a
        [ href props.releaseUrl]
        [ text "Release Link" ]
    , a
        [ href props.gvpLogUrl ]
        [ text "GVP Log Link" ]
    , a
        [ href props.gatherGroupsUrl ]
        [ text "RTM Report Link" ]
    , a
        [ href props.gatherGroupsUrl]
        [ text "Gather Groups Link" ]
-}
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
    , div [] [ text props.errors ]
    ]
