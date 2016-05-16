import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)

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
    name                  : String 
  , compileRunTypeSummary : RunTypeSummary.Model
  }

init : (Model, Cmd Msg)
init =
  (
    { name                  = "world",
      compileRunTypeSummary = RunTypeSummary.init "compiles" 0 0 0
    },
    Cmd.none
  )

type Msg 
  = NoOp
  | CompileSummary RunTypeSummary.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)

    CompileSummary compileMsg ->
      (model, Cmd.none)

view : Model -> Html Msg
view model =
  div []
    [ 
      h1 [] [ text ("Hello " ++ model.name) ],
      App.map CompileSummary (RunTypeSummary.view model.compileRunTypeSummary)
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
