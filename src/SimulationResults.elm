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
  [  (Simulation 1 "test1" "default" Pass Done 1154)
  ,  (Simulation 2 "test2" "pcie"    Pass Done 912)
  ,  (Simulation 3 "test3" "default" Pass Done 654)
  ,  (Simulation 4 "test4" "ddr"     Fail Exit 543)
  ,  (Simulation 5 "test5" "default" Pass Done 812)
  ,  (Simulation 6 "test6" "default" Pass Done 83)
  ,  (Simulation 7 "test7" "pcie"    Fail Exit 112)
  ,  (Simulation 8 "test8" "default" Fail Exit 352)
  ]

init : Model
init  =
  Model initialSimulations

type Msg
  = NoOp
  | SortByRunTime

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    SortByRunTime ->
      { model | simulations = List.reverse (List.sortBy .runTime model.simulations) } ! []

imageSpan : Html Msg
imageSpan =
  span
    []
    [
      img [src "images/glyphicons-405-sort-by-alphabet.png"] []
    ]


tableHeader : Html Msg
tableHeader =
  tr
    []
    [
      th [] [text "#"]
    , th [] [text "Name"]
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
      td [] [text (toString simulation.runNum)]
    , td [] [text simulation.name]
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
      button [ onClick SortByRunTime ] [text "sort"]
    , table 
        []
        (tableHeader :: (List.map tableRow model.simulations))
    ]
