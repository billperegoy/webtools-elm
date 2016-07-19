module Summary exposing (..)

import Api exposing (..)
import TimeUtils exposing (..)

type alias ViewData =
  {
    name : String
  , releaseLabel : String
  , runStatus : String
  , elapsedTime : Float
  , releaseUrl : String
  , gvpLogUrl : String
  , gatherGroupsUrl : String
  , rtmReportUrl : String
  }

init : ViewData
init =
  {
    name = ""
  , releaseLabel = ""
  , runStatus = ""
  , elapsedTime = 0
  , releaseUrl = "#"
  , gvpLogUrl = "#"
  , gatherGroupsUrl = "#"
  , rtmReportUrl = "#"
  }

fromApiData : Api.Summary -> ViewData
fromApiData apiData =
  let
    releaseLabel = Maybe.withDefault "" apiData.gvpLabel
    elapsedTime = elapsedRegressionTime apiData.startDate apiData.endDate
                                        apiData.elapsedTime
    runStatus =
      case apiData.elapsedTime of
        Nothing -> "Run"
        Just a -> "Done"
  in
    {
      name = apiData.runName
    , releaseLabel = releaseLabel
    , runStatus = runStatus
    , elapsedTime = elapsedTime
    , releaseUrl = "#"
    , gvpLogUrl = "#"
    , gatherGroupsUrl = "#"
    , rtmReportUrl = "#"
    }


elapsedRegressionTime : String -> Maybe String -> Maybe Float -> Float
elapsedRegressionTime startTime endTime elapsedTime =
  case elapsedTime of
    Just a -> a
    Nothing ->
      dateDifference startTime endTime
