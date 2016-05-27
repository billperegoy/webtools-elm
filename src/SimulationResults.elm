module SimulationResults exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List exposing (..)

import RegressionData exposing (..)

type alias Model =
  {
    simulations : List Simulation 
  }

initialSimulations : List Simulation 
initialSimulations =
  [  (Simulation "test1" "default" Pass Done 1154)
  ,  (Simulation "test2" "pcie"    Pass Done 912)
  ,  (Simulation "test3" "default" Pass Done 654)
  ,  (Simulation "test4" "ddr"     Fail Exit 543)
  ,  (Simulation "test5" "default" Pass Done 812)
  ,  (Simulation "test6" "default" Pass Done 83)
  ,  (Simulation "test7" "pcie"    Fail Exit 112)
  ,  (Simulation "test8" "default" Fail Exit 352)
  ]

init : Model
init  =
  Model initialSimulations

type Msg
  = NoOp

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

tableHeader : Html Msg
tableHeader =
  tr
    []
    [
      th [] [text "Name"]
    , th [] [text "Config"]
    , th [] [text "Status"]
    , th [] [text "Lsf Status"]
    , th [] [text "Run Time"]
    ]
tableRow : Simulation -> Html Msg
tableRow simulation =
  tr
    []
    [
      td [] [text simulation.name]
    , td [] [text simulation.config]
    , td [] [text (runStatusToString simulation.status)]
    , td [] [text simulation.config]
    , td [] [text (toString simulation.runTime)]
    ]

view : Model -> Html Msg
view model =
  div
    [ class "simulation-results" ]
    [ 
      table 
        []
        (tableHeader :: (List.map tableRow model.simulations))
    ]
