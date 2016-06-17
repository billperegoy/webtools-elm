import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Task exposing (..)
import Json.Decode as Json exposing (..)
import Time exposing (..)

import Initialize exposing (..)
import RegressionData exposing (..)
import RegressionSelect exposing (view)
import RegressionSummary exposing (view)
import ResultsTable exposing (view)

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
    runName : String
  , releaseLabel : String
  , runStatus : String
  , elapsedTime : Int
  , releaseUrl : String
  , gvpLogUrl : String
  , gatherGroupsUrl : String
  , rtmReportUrl : String
  , regressionSelect : RegressionSelect.Model
  , compileSummary : RunTypeSummaryData
  , lintSummary : RunTypeSummaryData
  , simSummary : RunTypeSummaryData
  , compileResults : ResultsTable.Model
  , lintResults : ResultsTable.Model
  , simResults : ResultsTable.Model
  , errors : String
  , tempData : List SingleRun 
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
  , compileSummary = emptySummaryData "compiles"
  , lintSummary = emptySummaryData "lints"
  , simSummary = emptySummaryData "sims"
  , compileResults = ResultsTable.init "Compiles" Initialize.initCompiles
  , lintResults = ResultsTable.init "Lints" Initialize.initLints
  , simResults = ResultsTable.init "Simulations" Initialize.initSimulations
  , errors = ""
  , tempData = []
  } ! []

getHttpData : Cmd Msg
getHttpData =
  let
    url = "http://localhost:4567/api/results"
  in
    Task.perform HttpFail HttpSucceed (Http.get decodeEverything url)

type Msg
  = NoOp
  | GetApiData
  | HttpSucceed AllResults
  | HttpFail Http.Error
  | PollHttp Time
  | CompileResults ResultsTable.Msg
  | LintResults ResultsTable.Msg
  | SimResults ResultsTable.Msg
  | RegressionSelect RegressionSelect.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    GetApiData ->
      (model, getHttpData)

    HttpSucceed results ->
      { 
        model
         | compileSummary = RunTypeSummaryData "compiles" results.summary.compiles
         , lintSummary = RunTypeSummaryData "lints" results.summary.lints
         , simSummary = RunTypeSummaryData "simulations" results.summary.sims
         , tempData = results.simulations
         , errors = ""
      } ! []

    HttpFail _ ->
      { model
         | errors = "HTTP error detected"
      } ! []

    PollHttp time ->
      (model, getHttpData)

    RegressionSelect msg ->
      { model
          | regressionSelect = fst(RegressionSelect.update msg model.regressionSelect)
      } ! []

    CompileResults msg ->
      { model
          | compileResults = fst(ResultsTable.update msg model.compileResults)
      } ! []

    LintResults msg ->
      { model
          | lintResults = fst(ResultsTable.update msg model.lintResults)
      } ! []

    SimResults msg ->
      { model
          | simResults = fst(ResultsTable.update msg model.simResults)
      } ! []


view : Model -> Html Msg
view model =
  div
    []
    [
      button [ onClick (SimResults (ResultsTable.UpdateData model.tempData)) ] [ text "Update Data" ]
    , div
        [ class "regression-select_container" ]
        [ App.map RegressionSelect (RegressionSelect.view model.regressionSelect) ]

    , (RegressionSummary.view model)
    , App.map CompileResults (ResultsTable.view model.compileResults)
    , App.map LintResults (ResultsTable.view model.lintResults)
    , App.map SimResults (ResultsTable.view model.simResults)
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Time.every (1000 * millisecond) PollHttp 
    --, Time.every (3000 * millisecond) (SimResults (ResultsTable.UpdateData []))
    ]
