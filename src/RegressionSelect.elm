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
  Model initialRegressions initialRegressions

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

filterByProject : List Regression -> List Regression
filterByProject unfiltered =
  unfiltered

filterByUser : List Regression -> List Regression
filterByUser unfiltered =
  unfiltered

filterByRunType : List Regression -> List Regression
filterByRunType unfiltered =
  unfiltered

{-
  This is where we add the code to actually do the 
  filtering based on the selects that were 
  chosen. Currently it just rturns an idential
  list
-}
filterIt : List Regression -> List Regression
filterIt unfiltered =
  filterByProject unfiltered 
    |> filterByUser
    |> filterByRunType

filteredRegressionList : Model -> List (Html Msg) 
filteredRegressionList model =
  filterIt model.regressions
  |> List.map .name 
  |> List.map toSelectOption

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

projectFilter : Model -> Html Msg 
projectFilter model =
      div 
        [ class "select-field" ]
        [
          label 
            []
            [ text "Projects" ]
        , select
            []
            (uniqueProjects model)
        ]

runTypeFilter : Model -> Html Msg 
runTypeFilter model =
      div 
        [ class "select-field" ]
        [
          label 
            []
            [ text "Run Types" ]
        , select
            []
            (uniqueRunTypes model)
        ]

userFilter : Model -> Html Msg 
userFilter model =
      div 
        [ class "select-field" ]
        [
          label 
            []
            [ text "Users" ]
        , select
            []
            (uniqueUsers model)
        ]

filterRegressions : Model -> Html Msg 
filterRegressions model =
  div
    [ class "filtered-select-field" ]
    [
      label 
         []
         [ text "Filtered List" ]
     , select
         []
         (filteredRegressionList model)
    ]


view : Model -> Html Msg
view model =
  div
    [ class "regression-select" ]
    [
      div 
        [ class "selectors" ]
        [
          (projectFilter model)
        , (runTypeFilter model)
        , (userFilter model)
        ]
    , (filterRegressions model)
    ]

