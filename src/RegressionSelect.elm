module RegressionSelect exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes as Attr exposing (..)
import List exposing (..)

import StringUtils exposing (uniquify)
import FormUtils as Form exposing (onSelectChange)
import HtmlUtils exposing (..)

import Initialize exposing (..)
import RegressionData exposing (..)

type alias Model =
  {
    regressions : List Regression
  , userFilter : String
  , projectFilter : String
  , runTypeFilter : String
  }


init : Model
init  =
  Model Initialize.initialRegressions "" "" ""

type Msg
  = NoOp
  | UpdateUserFilter String
  | UpdateProjectFilter String
  | UpdateRunTypeFilter String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    UpdateUserFilter data ->
      {
        model | 
          userFilter = data
      } ! []

    UpdateProjectFilter data ->
      { model | 
          projectFilter = data
      } ! []

    UpdateRunTypeFilter data ->
      { model | 
          runTypeFilter = data
      } ! []

filterBy : String -> List Regression -> String -> List Regression
filterBy filterType unfilteredList name =
  case filterType of
    "project" ->
      List.filter (\e -> e.project == name) unfilteredList

    "user" ->
      List.filter (\e -> e.user == name) unfilteredList

    "runType" ->
      List.filter (\e -> e.runType == name) unfilteredList

    _ -> unfilteredList


filterSelect : String -> String -> List Regression -> List Regression
filterSelect filterType name unfilteredList =
  if name == "" then
    unfilteredList
  else
    filterBy filterType unfilteredList name

filteredRegressionList : Model -> List (Html Msg)
filteredRegressionList model =
  model.regressions
    |> filterSelect "project" model.projectFilter
    |> filterSelect "user" model.userFilter
    |> filterSelect "runType" model.runTypeFilter
    |> List.map .name
    |> HtmlUtils.listToHtmlSelectOptions

allElementsByType : Model -> String -> List String
allElementsByType model selectType =
  case selectType of
  "project" ->
    "" :: List.map .project (model.regressions)

  "user" ->
    "" :: List.map .user (model.regressions)

  "runType" ->
    "" :: List.map .runType (model.regressions)

  _ -> []

uniqueElementsByType : Model -> String -> List (Html Msg)
uniqueElementsByType model selectType =
  allElementsByType model selectType
    |> StringUtils.uniquify
    |> List.map toSelectOption


--
-- view
--
filterHtml : Model -> String -> String -> (String -> Msg) -> Html Msg
filterHtml model filterLabel selectType msg =
      div
        [ class "select-field" ]
        [
          label
            []
            [ text filterLabel ]
        , select
            [ Form.onSelectChange msg ]
            (uniqueElementsByType model selectType)
        ]

filteredRegressionsHtml : Model -> Html Msg
filteredRegressionsHtml model =
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
          (filterHtml model "Projects" "project" UpdateProjectFilter)
        , (filterHtml model "Run Types" "runType" UpdateRunTypeFilter)
        , (filterHtml model "Users" "user" UpdateUserFilter)
        ]
    , (filteredRegressionsHtml model)
    ]

