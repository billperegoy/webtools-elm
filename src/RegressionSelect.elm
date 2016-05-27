module RegressionSelect exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List exposing (..)
import Set exposing (..)

import RegressionData exposing (..)

type alias Model =
  {
    regressions : List Regression
  , filteredRegressions : List Regression
  }

initialRegressions : List Regression
initialRegressions =
  [  (Regression "regression1" "project1" "validate" "user1")
  ,  (Regression "regression2" "project1" "publish" "user2")
  ,  (Regression "regression3" "project1" "validate" "user2")
  ,  (Regression "regression4" "project1" "validate" "user1")
  ,  (Regression "regression5" "project1" "validate" "user1")
  ,  (Regression "regression6" "project1" "publish" "user1")
  ,  (Regression "regression7" "project2" "publish" "user2")
  ,  (Regression "regression8" "project2" "validate" "user2")
  ,  (Regression "regression9" "project2" "validate" "user1")
  ,  (Regression "regression10" "project2" "validate" "user1")
  ,  (Regression "regression11" "project2" "publish" "user1")
  ,  (Regression "regression12" "project2" "regress" "user3")
  ]

init : Model
init  =
  Model initialRegressions []

type Msg
  = NoOp
  | Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    Update ->
      model ! []

toSelectOption : String -> Html Msg
toSelectOption elem =
  option [] [text elem]

filteredRegressionList : Model -> List (Html Msg) 
filteredRegressionList model =
  List.map .name model.regressions |> List.map toSelectOption

uniquify : List String -> List String
uniquify list =
  Set.fromList list |> Set.toList

uniqueProjects : Model -> List (Html Msg)
uniqueProjects model =
  "<all>" :: List.map .project (model.regressions)
    |> uniquify 
    |> List.map toSelectOption

uniqueRunTypes : Model -> List (Html Msg)
uniqueRunTypes model =
  "<all>" :: List.map .runType (model.regressions)
    |> uniquify 
    |> List.map toSelectOption

uniqueUsers : Model -> List (Html Msg)
uniqueUsers model =
  "<all>" :: List.map .user (model.regressions)
    |> uniquify 
    |> List.map toSelectOption

view : Model -> Html Msg
view model =
  div
    []
    [
      select
        []
        (filteredRegressionList model)
    , select
        []
        (uniqueProjects model)
    , select
        []
        (uniqueRunTypes model)
    , select
        []
        (uniqueUsers model)
    ]

