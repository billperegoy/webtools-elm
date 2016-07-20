module Summary exposing (..)

import Api exposing (..)
import TimeUtils exposing (..)

type alias ViewData =
  {
    name : String
  , releaseLabel : String
  , runStatus : String
  , elapsedTime : Float
  , startDate : String
  , endDate : String
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
  , startDate = ""
  , endDate = ""
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
    , startDate = apiData.startDate
    , endDate = apiData.endDate
    , elapsedTime = elapsedTime
    , releaseUrl = "#"
    , gvpLogUrl = "#"
    , gatherGroupsUrl = "#"
    , rtmReportUrl = "#"
    }


elapsedRegressionTime : String -> String -> Maybe Float -> Float
elapsedRegressionTime startTime endTime elapsedTime =
  case elapsedTime of
    Just a -> a
    Nothing ->
      dateStrDifferenceInSeconds startTime endTime
