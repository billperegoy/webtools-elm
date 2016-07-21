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
import RegressionSelect exposing (view, Regression)
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
  , runData : Api.Data
  , resultsHttpErrors : String
  , regressionsHttpErrors : String

  -- Sub-components
  , regressionSelect : RegressionSelect.Model
  , compileResults : ResultsTable.Model
  , lintResults : ResultsTable.Model
  , simResults : ResultsTable.Model

  }

init : (Model, Cmd Msg)
init =
  {
    regressionList = []
  , regressionSelect = RegressionSelect.init
  , compileResults = ResultsTable.init "Compiles" Initialize.initCompileColumns Initialize.initCompiles
  , lintResults = ResultsTable.init "Lints" Initialize.initLintColumns Initialize.initLints
  , simResults = ResultsTable.init "Simulations" Initialize.initSimColumns Initialize.initSimulations
  , resultsHttpErrors = ""
  , regressionsHttpErrors = ""

  , runData = Api.Data Initialize.initSummary [] [] []
  } ! []
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
          runData = results
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
          | compileResults = fst(ResultsTable.update msg model.compileResults 
                                   (compileApiDataToViewData model.runData.compiles))
      } ! []

    LintResults msg ->
      { model
          | lintResults = fst(ResultsTable.update msg model.lintResults 
                                (lintApiDataToViewData model.runData.lints))
      } ! []

    SimResults msg ->
      { model
          | simResults = fst(ResultsTable.update msg model.simResults
                               (simApiDataToViewData model.runData.simulations))
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
    Task.perform RegressionsHttpFail RegressionsHttpSucceed (Http.get RegressionSelect.decodeRegressionList url)

regressionSelectView : Model ->  Html Msg
regressionSelectView model = 
  div
    [ class "regression-select_container" ]
    [ App.map RegressionSelect (RegressionSelect.view model.regressionSelect model.regressionList) ]

view : Model -> Html Msg
view model =
  div
    []
    [
      regressionSelectView model
    , (RegressionSummary.view (Summary.summaryProps model.runData model.regressionsHttpErrors))
    , App.map CompileResults (ResultsTable.view model.compileResults
                                (compileApiDataToViewData model.runData.compiles))
    , App.map LintResults (ResultsTable.view model.lintResults
                             (lintApiDataToViewData model.runData.lints))
    , App.map SimResults (ResultsTable.view model.simResults
                             (simApiDataToViewData model.runData.simulations))
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ 
      Time.every (5000 * Time.millisecond) PollResultsHttp
    , Time.every (60000 * Time.millisecond) PollRegressionsHttp
    ]
