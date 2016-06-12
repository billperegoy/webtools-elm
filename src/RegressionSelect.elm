module RegressionSelect exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import List exposing (..)
import Json.Decode as Json exposing (..)
import Debug exposing (..)

import StringUtils exposing (uniquify)
import FormUtils as Form exposing (onSelectChange, AllSelectData)
import RegressionData exposing (..)

type alias Model =
  {
    regressions : List Regression
  , userFilter : String
  , projectFilter : String
  , runTypeFilter : String
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
  ,  (Regression "regression12" "project2" "regression" "user3")
  ]

init : Model
init  =
  Model initialRegressions "" "" ""

type Msg
  = NoOp
  | UpdateUserFilter Form.AllSelectData 
  | UpdateProjectFilter Form.AllSelectData
  | UpdateRunTypeFilter Form.AllSelectData

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    UpdateUserFilter data ->
      {
        model | 
          userFilter = data.target.value 
      } ! []

    UpdateProjectFilter data ->
      { model | 
          projectFilter = data.target.value 
      } ! []

    UpdateRunTypeFilter data ->
      { model | 
          runTypeFilter = data.target.value 
      } ! []

toSelectOption : String -> Html Msg
toSelectOption elem =
  option [] [text elem]

filterByProject : String -> List Regression -> List Regression
filterByProject project unfiltered =
  if project == "" then
    unfiltered
  else
    List.filter (\e -> e.project == project) unfiltered

filterByUser : String -> List Regression -> List Regression
filterByUser user unfiltered =
  if user == "" then
    unfiltered
  else
    List.filter (\e -> e.user == user) unfiltered

filterByRunType : String -> List Regression -> List Regression
filterByRunType runType unfiltered =
  if runType == "" then
    unfiltered
  else
    List.filter (\e -> e.runType == runType) unfiltered

filteredRegressionList : Model -> List (Html Msg)
filteredRegressionList model =
  model.regressions
    |> filterByProject model.projectFilter
    |> filterByUser model.userFilter
    |> filterByRunType model.runTypeFilter
    |> List.map .name
    |> List.map toSelectOption

uniqueProjects : Model -> List (Html Msg)
uniqueProjects model =
  "" :: List.map .project (model.regressions)
    |> StringUtils.uniquify
    |> List.map toSelectOption

uniqueRunTypes : Model -> List (Html Msg)
uniqueRunTypes model =
  "" :: List.map .runType (model.regressions)
    |> StringUtils.uniquify
    |> List.map toSelectOption

uniqueUsers : Model -> List (Html Msg)
uniqueUsers model =
  "" :: List.map .user (model.regressions)
    |> StringUtils.uniquify
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
            [ Attr.name "project-filter", Form.onSelectChange UpdateProjectFilter ]
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
            [ Attr.name "runtype-filter", onSelectChange UpdateRunTypeFilter ]
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
            [ Attr.name "user-filter", onSelectChange UpdateUserFilter ]
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

