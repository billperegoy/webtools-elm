import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)

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

type Msg 
  = NoOp
  | CompileSummary RunTypeSummary.Msg
  | LintSummary RunTypeSummary.Msg
  | SimSummary RunTypeSummary.Msg
  | AllSummary RunTypeSummary.Msg RunTypeSummary.Msg RunTypeSummary.Msg

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

    AllSummary compileMsg lintMsg simMsg ->
      { model 
         | compileSummary = fst(RunTypeSummary.update compileMsg model.compileSummary) 
         , lintSummary = fst(RunTypeSummary.update lintMsg model.lintSummary) 
         , simSummary = fst(RunTypeSummary.update simMsg model.simSummary) 
      } ! []

view : Model -> Html Msg
view model =
  let
    -- FIXME - eventually get this data from HTTP
    compileMsg = RunTypeSummary.Update 7 8 9
    lintMsg = RunTypeSummary.Update 10 11 12 
    simMsg = RunTypeSummary.Update 13 14 15 
  in
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
      button [onClick (AllSummary compileMsg lintMsg simMsg 
       )] [ text "Top Button" ]
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
