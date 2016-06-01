import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Task exposing (..)
import Json.Decode as Json exposing (..)
import Time exposing (..)

import RegressionData exposing(..)
import RegressionSelect exposing(view)
import RunTypeSummary exposing(view)
import SimulationResults exposing(view)
import ResultsTable exposing(view)

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
    regressionSelect : RegressionSelect.Model
  , compileSummary : RunTypeSummaryData
  , lintSummary : RunTypeSummaryData
  , simSummary : RunTypeSummaryData
  , simulationResults : SimulationResults.Model
  , lintResults : ResultsTable.Model
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
    regressionSelect = RegressionSelect.init
  , compileSummary = emptySummaryData "compiles"
  , lintSummary = emptySummaryData "lints"
  , simSummary = emptySummaryData "sims"
  , simulationResults = SimulationResults.init
  , lintResults = ResultsTable.init
  , errors = ""
  } ! []

getHttpData : Cmd Msg
getHttpData =
  let
    url = "http://localhost:4567/api/results"
  in
    Task.perform HttpFail HttpSucceed (Http.get decodeAll url)

type Msg
  = NoOp
  | GetApiData
  | HttpSucceed ResultsTriad
  | HttpFail Http.Error
  | PollHttp Time
  | SimulationResults SimulationResults.Msg
  | LintResults ResultsTable.Msg
  | RegressionSelect RegressionSelect.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    GetApiData ->
      (model, getHttpData)

    HttpSucceed triad ->
      { model
         | compileSummary = RunTypeSummaryData "compiles" triad.compiles
         , lintSummary = RunTypeSummaryData "lints" triad.lints
         , simSummary = RunTypeSummaryData "simulations" triad.sims
         , errors = ""
      } ! []

    HttpFail _ ->
      { model
         | errors = "HTTP error detected"
      } ! []

    PollHttp time ->
      (model, getHttpData)

    SimulationResults msg ->
      { model
          | simulationResults = fst(SimulationResults.update msg model.simulationResults)
      } ! []

    RegressionSelect msg ->
      { model
          | regressionSelect = fst(RegressionSelect.update msg model.regressionSelect)
      } ! []

    LintResults msg ->
      model ! []


view : Model -> Html Msg
view model =
  div
    []
    [
      div
        [ class "regression-select_container" ]
        [ App.map RegressionSelect (RegressionSelect.view model.regressionSelect) ]

    , div
        [ class "all-summaries" ]
        [
          div
            [ class "summary-container" ]
            [ (RunTypeSummary.view model.compileSummary) ]
        , div
            [ class "summary-container" ]
            [ (RunTypeSummary.view model.lintSummary) ]
        , div
            [ class "summary-container" ]
            [ (RunTypeSummary.view model.simSummary) ]
        ]
        , div
            [ class "error-box" ]
            [ text model.errors ]
    , div
        []
        [ App.map SimulationResults (SimulationResults.view model.simulationResults) ]
    , div
        []
        [ App.map LintResults (ResultsTable.view model.lintResults) ]

    ]


subscriptions : Model -> Sub Msg
subscriptions _ =
  Time.every (200 * millisecond) PollHttp
