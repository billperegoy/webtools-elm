import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Task exposing (..)
import Json.Decode as Json exposing (..)

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
  }

init : (Model, Cmd Msg)
init =
  (
    { 
      compileSummary = RunTypeSummary.init "compiles" 0 0 0
    , lintSummary = RunTypeSummary.init "lints" 0 0 0
    , simSummary = RunTypeSummary.init "sims" 0 0 0
    },
    Cmd.none
  )


type alias Results = { total : Int, complete : Int, fail : Int }

decodeUrl : Json.Decoder Results
decodeUrl =
  Json.object3 Results
    ("total" := Json.int)
    ("complete" := Json.int)
    ("fail" := Json.int)

getHttpData : Cmd Msg
getHttpData =
  let 
    url = "http://localhost:4567/api/results"
  in
    Task.perform FetchFail FetchSucceed (Http.get decodeUrl url)


type Msg 
  = NoOp
  | CompileSummary RunTypeSummary.Msg
  | LintSummary RunTypeSummary.Msg
  | SimSummary RunTypeSummary.Msg
  | GetApiData
  | FetchSucceed Results 
  | FetchFail Http.Error

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

    FetchSucceed value ->
      { model 
         | compileSummary = 
           fst(RunTypeSummary.update 
           (RunTypeSummary.Update value.total value.complete value.fail) model.compileSummary)
         , lintSummary = 
           fst(RunTypeSummary.update 
           (RunTypeSummary.Update value.total value.complete value.fail) model.lintSummary)
         , simSummary = 
           fst(RunTypeSummary.update 
           (RunTypeSummary.Update value.total value.complete value.fail) model.simSummary)
      } ! []

    FetchFail _ ->
      model ! []

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
        ],
      button [onClick GetApiData] [ text "Top Button" ]
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
