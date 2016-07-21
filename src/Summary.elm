module Summary exposing (..)

import Api exposing (..)
import TimeUtils exposing (..)
import String exposing (..)


type alias SingleRun =
  {
    runNum : Int
  , name : String
  , config : String
  , status : String
  , lsfInfo : LsfViewData
  }

type alias SingleResult =
  {
    total : Int
  , complete : Int
  , failed : Int
  }

type alias RunTypeSummaryData =
  { label : String
  , result : SingleResult
  }

type alias LsfViewData =
  {
    jobId : String
  , status : String
  , execHost : String
  , elapsedTime : Int
  }

type alias AllRunTypeSummaries =
  {
    errors : String
  , runSummary : ViewData
  , compileSummary : RunTypeSummaryData
  , lintSummary : RunTypeSummaryData
  , simSummary : RunTypeSummaryData
  }

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
    elapsedTime = TimeUtils.elapsedRegressionTime apiData.startDate apiData.endDate
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

completedRun : SingleRun -> Bool
completedRun run =
  (String.toLower run.lsfInfo.status == "done") || (String.toLower run.lsfInfo.status == "exit")

failedRun : SingleRun -> Bool
failedRun run =
  (String.toLower run.status == "fail") || (String.toLower run.status == "error")

summarizeData : String -> List SingleRun -> RunTypeSummaryData
summarizeData label data =
  let
    total = List.length data

    complete = data
      |> List.filter completedRun |> List.length

    failed = data
      |> List.filter failedRun |> List.length
  in
    RunTypeSummaryData label (SingleResult total complete failed)

convertApiLsfDataToViewLsfData : Api.LsfInfo -> LsfViewData
convertApiLsfDataToViewLsfData apiData =
  {
    jobId = apiData.jobId
  , status = apiData.status
  , execHost = apiData.execHost
  , elapsedTime = Maybe.withDefault 0 apiData.elapsedTime
  }

convertCompileApiDataToSingleResult : Api.Compile -> SingleRun
convertCompileApiDataToSingleResult apiData =
  {
    runNum = 0
  , name = apiData.name
  , config = apiData.config
  , status = apiData.runStatus
  , lsfInfo = convertApiLsfDataToViewLsfData apiData.lsfInfo
  }

convertLintApiDataToSingleResult : Api.Lint -> SingleRun
convertLintApiDataToSingleResult apiData =
  {
    runNum = 0
  , name = "x"
  , config = ""
  , status = ""
  , lsfInfo = convertApiLsfDataToViewLsfData apiData.lsfInfo
  }

convertSimApiDataToSingleResult : Api.Simulation -> SingleRun
convertSimApiDataToSingleResult apiData =
  {
    runNum = apiData.testId
  , name = apiData.name
  , config = apiData.config
  , status = apiData.runStatus
  , lsfInfo = convertApiLsfDataToViewLsfData apiData.lsfInfo
  }

compileApiDataToViewData data =
  List.map (\e -> convertCompileApiDataToSingleResult e) data

lintApiDataToViewData data =
  List.map (\e -> convertLintApiDataToSingleResult e) data

simApiDataToViewData data =
  List.map (\e -> convertSimApiDataToSingleResult e) data

summaryProps : Api.Data -> String -> AllRunTypeSummaries
summaryProps runData errors  =
  {
    errors = errors
  , runSummary = fromApiData runData.summary
  , compileSummary = summarizeData "compiles" (compileApiDataToViewData runData.compiles)
  , lintSummary = summarizeData "lints" (lintApiDataToViewData runData.lints)
  , simSummary = summarizeData "sims" (simApiDataToViewData runData.simulations)
  }
