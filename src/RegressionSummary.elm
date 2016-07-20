module RegressionSummary exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

import TimeUtils exposing (..)
import RunTypeSummary exposing (..)

-- FIXME - can't properly type this. need to organize types.
--view : Summary.ViewData
view props =
  div
    [ class "regression-summary" ]
    [
      div
        []
        [ text ("Run Name: " ++ props.runSummary.name) ]
    , div
        []
        [ text ("Release Label: " ++ props.runSummary.releaseLabel) ]
    , div
        []
        [ text ("Run Status: " ++ props.runSummary.runStatus) ]
    , div
        []
        [ text "Progress Bar" ]
    , div
        []
        [ text ("Elapsed Time: " ++ TimeUtils.durationToString((dateStrDifferenceInSeconds props.runSummary.startDate props.runSummary.endDate))) ]
        --[ text ("Elapsed Time: " ++ TimeUtils.durationToString props.runSummary.elapsedTime) ]
    , a
        [ href props.runSummary.releaseUrl]
        [ text "Release Link" ]
    , a
        [ href props.runSummary.gvpLogUrl ]
        [ text "GVP Log Link" ]
    , a
        [ href props.runSummary.gatherGroupsUrl ]
        [ text "RTM Report Link" ]
    , a
        [ href props.runSummary.gatherGroupsUrl]
        [ text "Gather Groups Link" ]
    , div
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
