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

--
-- We return a tuple consisting of an initailized model and a Cmd
-- In this case the Cmd is empty.
-- Note that ({...}, Cmd.none) is the same as {...} ! []
--
init : (Model, Cmd Msg)
init =
  {
    compileSummary = RunTypeSummary.init "compiles" emptyResult
  , lintSummary = RunTypeSummary.init "lints" emptyResult
  , simSummary = RunTypeSummary.init "sims" emptyResult
  , errors = ""
  } ! []

getHttpData : Cmd Msg
getHttpData =
  let
    url = "http://localhost:4567/api/results"
  in
    Task.perform FetchFail FetchSucceed (Http.get decodeAll url)

type Msg
  = NoOp
  | GetApiData
  | FetchSucceed ResultsTriad
  | FetchFail Http.Error
  | PollHttp Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    GetApiData ->
      (model, getHttpData)

    FetchSucceed triad ->
      { model
         | compileSummary =
           fst(RunTypeSummary.update
           (RunTypeSummary.Update triad.compiles) model.compileSummary)
         , lintSummary =
           fst(RunTypeSummary.update
           (RunTypeSummary.Update triad.lints) model.lintSummary)
         , simSummary =
           fst(RunTypeSummary.update
           (RunTypeSummary.Update triad.sims) model.simSummary)
         , errors = ""
      } ! []

    FetchFail _ ->
      { model 
         | errors = "HTTP error detected"
      } ! []

    PollHttp time ->
      (model, getHttpData)


msgToNoOp : RunTypeSummary.Msg -> Msg 
msgToNoOp cmd =
  NoOp

view : Model -> Html Msg
view model =
  div
    []
    [
      div
        [ class "all-summaries" ]
        [
          --
          -- Note that to instantiate a nested view, you have to deal with any
          -- transform any Msg produced by the subtree. In this case since I
          -- know nothing travels in that direction, I just map to a NoOp
          -- 
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
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every (200 * millisecond) PollHttp
