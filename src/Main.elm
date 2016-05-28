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
  , compileSummary : RunTypeSummary.Model
  , lintSummary : RunTypeSummary.Model
  , simSummary : RunTypeSummary.Model
  , simulationResults : SimulationResults.Model
  , errors : String
  }

emptyResult : SingleResult
emptyResult =
  SingleResult 0 0 0

{-
   We return a tuple consisting of an initailized model and a Cmd
   In this case the Cmd is empty.
   Note that ({...}, Cmd.none) is the same as {...} ! []
-}
init : (Model, Cmd Msg)
init =
  {
     regressionSelect = RegressionSelect.init
  ,  compileSummary = RunTypeSummary.init "compiles" emptyResult
  , lintSummary = RunTypeSummary.init "lints" emptyResult
  , simSummary = RunTypeSummary.init "sims" emptyResult
  , simulationResults = SimulationResults.init
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

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    GetApiData ->
      (model, getHttpData)

    {-
       Here I call upadte on each of the nested components using the triad
       values I got from the Http calls
    -}
    HttpSucceed triad ->
      { model
         | compileSummary =
           RunTypeSummary.updateNoCmd
             (RunTypeSummary.Update triad.compiles) model.compileSummary
         , lintSummary =
           RunTypeSummary.updateNoCmd
             (RunTypeSummary.Update triad.lints) model.lintSummary
         , simSummary =
           RunTypeSummary.updateNoCmd
             (RunTypeSummary.Update triad.sims) model.simSummary
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



msgToNoOp : RunTypeSummary.Msg -> Msg
msgToNoOp cmd =
  NoOp

regressionSelectMsgToNoOp : RegressionSelect.Msg -> Msg
regressionSelectMsgToNoOp cmd =
  NoOp

simulationResultsMsgToNoOp : SimulationResults.Msg -> Msg
simulationResultsMsgToNoOp cmd =
  NoOp

view : Model -> Html Msg
view model =
  div
    []
    [
      div
        [ class "regression-select_container" ]
        [ App.map  regressionSelectMsgToNoOp (RegressionSelect.view model.regressionSelect) ] 

    , div
        [ class "all-summaries" ]
        [
          {-
             Note that to instantiate a nested view, you have to deal with and
             transform any Msg produced by the subtree. In this case since I
             know nothing travels in that direction, I just map to a NoOp
          -}
          div
            [ class "summary-container" ]
            [ App.map msgToNoOp (RunTypeSummary.view model.compileSummary) ]
        , div
            [ class "summary-container" ]
            [ App.map msgToNoOp (RunTypeSummary.view model.lintSummary) ]
        , div
            [ class "summary-container" ]
            [ App.map msgToNoOp (RunTypeSummary.view model.simSummary) ]
        ]
        , div
            [ class "error-box" ]
            [ text model.errors ]
    , div
        []
        {-
           Note that instead of passing a NoOp as the map function,
           I actually send the command to the child module
        -}
        [ App.map SimulationResults (SimulationResults.view model.simulationResults) ] 

    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every (200 * millisecond) PollHttp
