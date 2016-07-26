import Html exposing (Html, div)
import Html.App as App
import Html.Attributes exposing (class)
import Http exposing (Error)
import Task exposing (perform)
import Time exposing (Time)

import Initialize exposing (..)
import Config exposing (..)
import RegressionSelect exposing (view)
import RegressionSelectData exposing (..)
import RegressionSummary exposing (view)
import ResultsTable exposing (view)
import Api exposing (..)
import ViewData exposing (..)

--
-- App
--
main : Program Never
main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

--
-- Model
--
type alias Model =
  {
    regressionList : List Regression
  , regressionsHttpErrors : String

  , runData : Api.Data
  , resultsHttpErrors : String

  -- Sub-components
  , regressionSelect : RegressionSelect.Model
  , compileResults : ResultsTable.Model
  , lintResults : ResultsTable.Model
  , simResults : ResultsTable.Model

  }

--
-- Init
--
init : (Model, Cmd Msg)
init =
  {
    regressionList = []
  , regressionsHttpErrors = ""

  , runData = Api.Data Initialize.initSummary [] [] []
  , resultsHttpErrors = ""

  , regressionSelect = RegressionSelect.init
  , compileResults = ResultsTable.init "Compiles" Config.initCompileColumns []
  , lintResults = ResultsTable.init "Lints" Config.initLintColumns []
  , simResults = ResultsTable.init "Simulations" Config.initSimColumns []
  } ! [ getRegressionsHttpData ]


--
-- Update 
--
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
      let 
        (result, effect, newSelection) = RegressionSelect.update msg model.regressionSelect
        newModel = { model | regressionSelect = result }
      in
        case newSelection of
          Nothing ->
            (newModel, Cmd.none)
          Just a ->
            (newModel, getResultsHttpData a)

    CompileResults msg ->
      let
        viewProps = ViewData.fromCompileApiData model.runData.compiles
        (result, _) = ResultsTable.update msg model.compileResults viewProps
        newModel = { model | compileResults = result }
      in
        newModel ! []

    LintResults msg ->
      let
        viewProps = ViewData.fromLintApiData model.runData.lints
        (result, _) = ResultsTable.update msg model.lintResults viewProps
        newModel = { model | lintResults = result }
      in
        newModel ! []

    SimResults msg ->
      let
        viewProps = ViewData.fromSimApiData model.runData.simulations
        (result, _) = ResultsTable.update msg model.simResults viewProps
        newModel = { model | simResults = result }
      in
        newModel ! []

getResultsHttpData : String -> Cmd Msg
getResultsHttpData regressionName =
  let
    url = Config.apiBase ++ "regressions" ++ "/" ++ regressionName
  in
    Task.perform ResultsHttpFail ResultsHttpSucceed
      (Http.get Api.decodeData url)

getRegressionsHttpData : Cmd Msg
getRegressionsHttpData =
  let
    url = Config.apiBase ++ "regressions"
  in
    Task.perform RegressionsHttpFail RegressionsHttpSucceed
      (Http.get RegressionSelectData.decodeRegressionList url)

--
-- View 
--
view : Model -> Html Msg
view model =
  div
    []
    [
      regressionSelectView model
    , (RegressionSummary.view (ViewData.summaryProps model.runData model.regressionsHttpErrors))
    , App.map CompileResults (ResultsTable.view model.compileResults
        (ViewData.fromCompileApiData model.runData.compiles))
    , App.map LintResults (ResultsTable.view model.lintResults
        (ViewData.fromLintApiData model.runData.lints))
    , App.map SimResults (ResultsTable.view model.simResults
        (ViewData.fromSimApiData model.runData.simulations))
    ]

regressionSelectView : Model ->  Html Msg
regressionSelectView model = 
  div
    [ class "regression-select_container" ]
    [ App.map RegressionSelect (RegressionSelect.view model.regressionSelect model.regressionList) ]


--
-- Subscriptions
--
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ 
      Time.every (5000 * Time.millisecond) PollResultsHttp
    , Time.every (60000 * Time.millisecond) PollRegressionsHttp
    ]
