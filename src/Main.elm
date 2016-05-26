import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Task exposing (..)
import Json.Decode as Json exposing (..)
import Time exposing (..)

import RegressionData exposing(..)
import RunTypeSummary exposing(view)

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
    compileSummary : RunTypeSummary.Model
  , lintSummary : RunTypeSummary.Model
  , simSummary : RunTypeSummary.Model
  , errors : String
  }

emptyResult : SingleResult
emptyResult =
  SingleResult 0 0 0

init : (Model, Cmd Msg)
init =
  (
    {
      compileSummary = RunTypeSummary.init "compiles" emptyResult
    , lintSummary = RunTypeSummary.init "lints" emptyResult
    , simSummary = RunTypeSummary.init "sims" emptyResult
    , errors = ""
    },
    Cmd.none
  )

getHttpData : Cmd Msg
getHttpData =
  let
    url = "http://localhost:4567/api/results"
  in
    Task.perform FetchFail FetchSucceed (Http.get decodeAll url)


lintResult : ResultsTriad -> SingleResult
lintResult triad = 
  SingleResult triad.lints.total triad.lints.complete triad.lints.failed

compileResult : ResultsTriad -> SingleResult
compileResult triad = 
  SingleResult triad.compiles.total triad.compiles.complete triad.compiles.failed

simResult : ResultsTriad -> SingleResult
simResult triad = 
  SingleResult triad.sims.total triad.sims.complete triad.sims.failed

type Msg
  = NoOp
  | CompileSummary RunTypeSummary.Msg
  | LintSummary RunTypeSummary.Msg
  | SimSummary RunTypeSummary.Msg
  | GetApiData
  | FetchSucceed ResultsTriad
  | FetchFail Http.Error
  | PollHttp Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    CompileSummary msg ->
      { model | compileSummary = fst(RunTypeSummary.update msg model.compileSummary) } ! []

    LintSummary msg ->
      { model | lintSummary = fst(RunTypeSummary.update msg model.lintSummary) } ! []

    SimSummary msg ->
      { model | simSummary = fst(RunTypeSummary.update msg model.simSummary) } ! []

    GetApiData ->
      (model, getHttpData)

    FetchSucceed triad ->
      { model
         | compileSummary =
           fst(RunTypeSummary.update
           (RunTypeSummary.Update (compileResult triad)) model.compileSummary)
         , lintSummary =
           fst(RunTypeSummary.update
           (RunTypeSummary.Update (lintResult triad)) model.compileSummary)
         , simSummary =
           fst(RunTypeSummary.update
           (RunTypeSummary.Update (simResult triad)) model.simSummary)
         , errors = ""
      } ! []

    FetchFail _ ->
      { model 
         | errors = "HTTP error detected"
      } ! []

    PollHttp time ->
      (model, getHttpData)

view : Model -> Html Msg
view model =
  div
    []
    [
      div
        [ class "all-summaries" ]
        [
          div
            [ class "summary-container" ]
            [ App.map CompileSummary (RunTypeSummary.view model.compileSummary) ]
        , div
            [ class "summary-container" ]
            [ App.map LintSummary (RunTypeSummary.view model.lintSummary) ]
        , div
            [ class "summary-container" ]
            [ App.map SimSummary (RunTypeSummary.view model.simSummary) ]
        ]
        , div
            [ class "error-box" ]
            [ text model.errors ]
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every (200 * millisecond) PollHttp
