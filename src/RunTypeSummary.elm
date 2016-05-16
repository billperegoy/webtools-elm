module RunTypeSummary exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)

type alias Model =
  { label : String
  , total : Int
  , runnng : Int
  , failed : Int
  }

init : String -> Int -> Int -> Int -> Model
init label total running failed =
  Model label total running failed
 
type Msg
  = NoOp

view : Model -> Html Msg
view model =
  div []
    [
      h2 [] [ text "ViewTypeSummary" ]
    ]

