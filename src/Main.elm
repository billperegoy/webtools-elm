import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Task exposing (..)
import Json.Decode as Json exposing (..)
import Time exposing (..)
import String exposing (..)
import Date exposing (..)

import Initialize exposing (..)
import RegressionData exposing (..)
import RegressionSelect exposing (view)
import RegressionSummary exposing (view)
import ResultsTable exposing (view)
import Api exposing (..)
import Summary exposing (..)

main : Program Never
main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

type alias Model =
  {
    regressionList : List Regression

  , summaryData : Api.Summary 
  , compileData : List Api.Compile
  , lintData : List Api.Lint
  , simData : List Api.Simulation

  -- Sub-components
  , regressionSelect : RegressionSelect.Model
  , compileResults : ResultsTable.Model
  , lintResults : ResultsTable.Model
  , simResults : ResultsTable.Model

  , resultsHttpErrors : String
  , regressionsHttpErrors : String
  }

emptySummaryData : String -> RunTypeSummaryData
emptySummaryData label =
  RunTypeSummaryData label (SingleResult 0 0 0)

{-
   We return a tuple consisting of an initailized model and a Cmd
   In this case the Cmd is empty.
   Note that ({...}, Cmd.none) is the same as {...} ! []
-}
init : (Model, Cmd Msg)
init =
  {
    regressionList = Initialize.initRegressions
  , regressionSelect = RegressionSelect.init
  , compileResults = ResultsTable.init "Compiles" Initialize.initCompileColumns Initialize.initCompiles
  , lintResults = ResultsTable.init "Lints" Initialize.initLintColumns Initialize.initLints
  , simResults = ResultsTable.init "Simulations" Initialize.initSimColumns Initialize.initSimulations
  , resultsHttpErrors = ""
  , regressionsHttpErrors = ""

  , summaryData = Initialize.initSummary
  , lintData = []
  , compileData = []
  , simData = []
  } ! []

getResultsHttpData : String -> Cmd Msg
getResultsHttpData regressionName =
  let
    url = "http://localhost:9292/api/regressions/" ++ regressionName
  in
    Task.perform ResultsHttpFail ResultsHttpSucceed (Http.get Api.decodeData url)

getRegressionsHttpData : Cmd Msg
getRegressionsHttpData =
  let
    url = "http://localhost:9292/api/regressions"
  in
    Task.perform RegressionsHttpFail RegressionsHttpSucceed (Http.get decodeRegressionList url)

type Msg
  = RegressionSelect RegressionSelect.Msg

  | ResultsHttpSucceed Api.Data
  | ResultsHttpFail Http.Error
  | PollResultsHttp Time

  | RegressionsHttpSucceed (List Regression) 
  | RegressionsHttpFail Http.Error
  | PollRegressionsHttp Time

  | CompileResults ResultsTable.Msg
  | LintResults ResultsTable.Msg
  | SimResults ResultsTable.Msg

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

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    RegressionsHttpSucceed results ->
      { model |
          regressionList = results
        , regressionsHttpErrors = ""
      } ! []

    RegressionsHttpFail error ->
      { model |
          regressionsHttpErrors = "Http errors: " ++ toString error 
      } ! []

    PollRegressionsHttp time ->
      (model, getRegressionsHttpData)

    ResultsHttpSucceed results ->
      { model |
          summaryData = results.summary
        , compileData = results.compiles
        , lintData = results.lints
        , simData = results.simulations
        , resultsHttpErrors = ""
       } ! []

    ResultsHttpFail error ->
      { model
         | resultsHttpErrors = "HTTP error detected: " ++ toString error
      } ! []

    PollResultsHttp time ->
      (model, getResultsHttpData model.regressionSelect.selectedElement)

    RegressionSelect msg ->
      { model
          | regressionSelect = fst(RegressionSelect.update msg model.regressionSelect)
      } ! []

    CompileResults msg ->
      { model
          | compileResults = fst(ResultsTable.update msg model.compileResults (compileApiDataToViewData model.compileData))
      } ! []

    LintResults msg ->
      { model
          | lintResults = fst(ResultsTable.update msg model.lintResults (lintApiDataToViewData model.lintData))
      } ! []

    SimResults msg ->
      { model
          | simResults = fst(ResultsTable.update msg model.simResults (simApiDataToViewData model.simData))
      } ! []


convertDateString dateStr =
  let
    date = Date.fromString dateStr
  in
    case date of
      Ok a ->
        a
      Err  _->
        fromTime 0

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

type alias AllRunTypeSummaries =
  {
    errors : String
  , runSummary : Summary.ViewData 
  , compileSummary : RunTypeSummaryData
  , lintSummary : RunTypeSummaryData
  , simSummary : RunTypeSummaryData
  }

summaryProps : Model -> AllRunTypeSummaries
summaryProps model =
  { 
    errors = model.resultsHttpErrors
  , runSummary = Summary.fromApiData model.summaryData
  , compileSummary = summarizeData "compiles" (compileApiDataToViewData model.compileData)
  , lintSummary = summarizeData "lints" (lintApiDataToViewData model.lintData)
  , simSummary = summarizeData "sims" (simApiDataToViewData model.simData)
  }

compileApiDataToViewData data =
  List.map (\e -> convertCompileApiDataToSingleResult e) data 

lintApiDataToViewData data =
  List.map (\e -> convertLintApiDataToSingleResult e) data

simApiDataToViewData data =
  List.map (\e -> convertSimApiDataToSingleResult e) data

view : Model -> Html Msg
view model =
  div
    []
    [
      div
        [ class "regression-select_container" ]
        [ App.map RegressionSelect (RegressionSelect.view model.regressionSelect model.regressionList) ]
    , p [] [ text model.regressionsHttpErrors ]

    , (RegressionSummary.view (summaryProps model))
    , App.map CompileResults (ResultsTable.view model.compileResults (compileApiDataToViewData model.compileData))
    , App.map LintResults (ResultsTable.view model.lintResults (lintApiDataToViewData model.lintData))
    , App.map SimResults (ResultsTable.view model.simResults (simApiDataToViewData model.simData))
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ 
      Time.every (5000 * Time.millisecond) PollResultsHttp
    , Time.every (60000 * Time.millisecond) PollRegressionsHttp
    ]
