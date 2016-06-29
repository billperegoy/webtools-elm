import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Task exposing (..)
import Json.Decode as Json exposing (..)
import Time exposing (..)
import String exposing (..)

import Initialize exposing (..)
import RegressionData exposing (..)
import RegressionSelect exposing (view)
import RegressionSummary exposing (view)
import ResultsTable exposing (view)
import ApiDataTypes exposing (..)

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
  -- FIXME - This should all be embedded in a sub-type
  --         to simp;lify the model.
  --         Some of this is likley derived as well.
  --
    runName : String
  , releaseLabel : String
  , runStatus : String
  , elapsedTime : Int
  , releaseUrl : String
  , gvpLogUrl : String
  , gatherGroupsUrl : String
  , rtmReportUrl : String

  , compileData : List SingleRun
  , lintData : List SingleRun
  , simData : List SingleRun

  , regressionSelect : RegressionSelect.Model

  --
  , compileResults : ResultsTable.Model
  , lintResults : ResultsTable.Model
  , simResults : ResultsTable.Model

  , errors : String
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
    runName = "My Run Name"
  , releaseLabel = "My Release Label"
  , runStatus = "RUN"
  , elapsedTime = 1234
  , releaseUrl = "#"
  , gvpLogUrl = "#"
  , gatherGroupsUrl = "#"
  , rtmReportUrl = "#"
  , regressionSelect = RegressionSelect.init
  , compileResults = ResultsTable.init "Compiles" Initialize.initCompileColumns Initialize.initCompiles
  , lintResults = ResultsTable.init "Lints" Initialize.initLintColumns Initialize.initLints
  , simResults = ResultsTable.init "Simulations" Initialize.initSimColumns Initialize.initSimulations
  , errors = ""
  , lintData = []
  , compileData = []
  , simData = []
  } ! []

getHttpData : Cmd Msg
getHttpData =
  let
    url = "http://localhost:9292/api/results"
  in
    Task.perform HttpFail HttpSucceed (Http.get decodeTopApiData url)

type Msg
  = RegressionSelect RegressionSelect.Msg
  | GetApiData
  | HttpSucceed TopApiData
  | HttpFail Http.Error
  | PollHttp Time
  | CompileResults ResultsTable.Msg
  | LintResults ResultsTable.Msg
  | SimResults ResultsTable.Msg


convertApiLsfDataToViewLsfData : LsfApiData -> LsfViewData
convertApiLsfDataToViewLsfData apiData =
  {
    jobId = apiData.jobId
  , status = apiData.status
  , execHost = apiData.execHost
  , elapsedTime = apiData.elapsedTime
  }

convertCompileApiDataToSingleResult : CompileApiData -> SingleRun
convertCompileApiDataToSingleResult apiData =
  {
    runNum = 0
  , name = apiData.name
  , config = apiData.config
  , status = apiData.runStatus
  , lsfInfo = convertApiLsfDataToViewLsfData apiData.lsfInfo
  }

{- FIXME
convertLintApiDataToSingleResult : LintApiData -> SingleRun
convertLintApiDataToSingleResult apiData =
  {
    runNum = 0 
  , name = "x" 
  , config = "" 
  , status = "" 
  , lsfInfo = convertApiLsfDataToViewLsfData apiData.lsfInfo
  }
-}

convertSimApiDataToSingleResult : SimulationApiData -> SingleRun
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
    GetApiData ->
      (model, getHttpData)

    HttpSucceed results ->
      { model |
          compileData = List.map (\e -> convertCompileApiDataToSingleResult e) results.compiles
        --, lintData = List.map (\e -> convertLintApiDataToSingleResult e) results.lints
        , simData = List.map (\e -> convertSimApiDataToSingleResult e) results.simulations
        , errors = ""
      } ! []

    HttpFail error ->
      { model
         | errors = "HTTP error detected: " ++ toString error
      } ! []

    PollHttp time ->
      (model, getHttpData)

    RegressionSelect msg ->
      { model
          | regressionSelect = fst(RegressionSelect.update msg model.regressionSelect)
      } ! []

    CompileResults msg ->
      { model
          | compileResults = fst(ResultsTable.update msg model.compileResults model.compileData)
      } ! []

    LintResults msg ->
      { model
          | lintResults = fst(ResultsTable.update msg model.lintResults model.lintData)
      } ! []

    SimResults msg ->
      { model
          | simResults = fst(ResultsTable.update msg model.simResults model.simData)
      } ! []


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
  , compileSummary : RunTypeSummaryData
  , lintSummary : RunTypeSummaryData
  , simSummary : RunTypeSummaryData
  }

summaryProps : Model -> AllRunTypeSummaries
summaryProps model =
  { 
    errors = model.errors
  , compileSummary = summarizeData "compiles" model.compileData
  , lintSummary = summarizeData "lints" model.lintData
  , simSummary = summarizeData "sims" model.simData
  }

view : Model -> Html Msg
view model =
  div
    []
    [
      div
        [ class "regression-select_container" ]
        [ App.map RegressionSelect (RegressionSelect.view model.regressionSelect) ]

    , (RegressionSummary.view (summaryProps model))
    , App.map CompileResults (ResultsTable.view model.compileResults model.compileData)
    , App.map LintResults (ResultsTable.view model.lintResults model.lintData)
    , App.map SimResults (ResultsTable.view model.simResults model.simData)
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Time.every (5000 * millisecond) PollHttp
    ]
