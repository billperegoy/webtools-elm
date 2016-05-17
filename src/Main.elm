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
    compileRunTypeSummary : RunTypeSummary.Model
  , lintRunTypeSummary : RunTypeSummary.Model
  , simRunTypeSummary : RunTypeSummary.Model
  }

init : (Model, Cmd Msg)
init =
  (
    { compileRunTypeSummary = RunTypeSummary.init "compiles" 0 0 0
    , lintRunTypeSummary = RunTypeSummary.init "lints" 0 0 0
    , simRunTypeSummary = RunTypeSummary.init "sims" 0 0 0
    },
    Cmd.none
  )

type Msg 
  = NoOp
  | CompileSummary RunTypeSummary.Msg
  | LintSummary RunTypeSummary.Msg
  | SimSummary RunTypeSummary.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)

    CompileSummary compileMsg ->
      (model, Cmd.none)

    LintSummary lintMsg ->
      (model, Cmd.none)

    SimSummary simMsg ->
      (model, Cmd.none)

view : Model -> Html Msg
view model =
  div []
    [ 
      App.map CompileSummary (RunTypeSummary.view model.compileRunTypeSummary)
    , App.map LintSummary (RunTypeSummary.view model.lintRunTypeSummary)
    , App.map SimSummary (RunTypeSummary.view model.simRunTypeSummary)
    , button [onClick (CompileSummary (RunTypeSummary.Update 4 5 6)) ] [ text "Top Button" ]
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
