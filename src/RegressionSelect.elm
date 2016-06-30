module RegressionSelect exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes as Attr exposing (..)

import StringUtils exposing (uniquify)
import FormUtils as Form exposing (onSelectChange)
import HtmlUtils exposing (listToHtmlSelectOptions)

import Initialize exposing (..)
import RegressionData exposing (..)

--
-- Model
--
type alias Model =
  {
    userFilter : String
  , projectFilter : String
  , runTypeFilter : String
  , selectedElement : String
  }


init : Model
init  =
  Model "" "" "" ""

--
-- Update
--
type Msg
  = UpdateUserFilter String
  | UpdateProjectFilter String
  | UpdateRunTypeFilter String
  | UpdateSelectedElement String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UpdateUserFilter data ->
      { model | userFilter = data } ! []

    UpdateProjectFilter data ->
      { model | projectFilter = data } ! []

    UpdateRunTypeFilter data ->
      { model | runTypeFilter = data } ! []

    UpdateSelectedElement data ->
      { model | selectedElement = data } ! []

--
-- View Utilities
--
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

filteredRegressionList : Model -> List Regression -> List (Html Msg)
filteredRegressionList model regressions =
  regressions
    |> filterSelect "project" model.projectFilter
    |> filterSelect "user" model.userFilter
    |> filterSelect "runType" model.runTypeFilter
    |> List.map .name
    |> HtmlUtils.listToHtmlSelectOptions

allElementsByType : Model -> List Regression -> String -> List String
allElementsByType model regressions selectType =
  case selectType of
  "project" ->
    "" :: List.map .project regressions

  "user" ->
    "" :: List.map .user regressions

  "runType" ->
    "" :: List.map .runType regressions

  _ -> []

uniqueElementsByTypeToHtmlSelect : Model -> List Regression -> String -> List (Html Msg)
uniqueElementsByTypeToHtmlSelect model regressions selectType =
  allElementsByType model regressions selectType
    |> StringUtils.uniquify
    |> HtmlUtils.listToHtmlSelectOptions

--
-- view
--
filterElementHtml : Model -> List Regression -> String -> String -> (String -> Msg) -> Html Msg
filterElementHtml model regressions filterLabel selectType msg =
      div
        [ class "select-field" ]
        [
          label
            []
            [ text filterLabel ]
        , select
            [ Form.onSelectChange msg ]
            (uniqueElementsByTypeToHtmlSelect model regressions selectType)
        ]

filteredRegressionsHtml : Model -> List Regression -> Html Msg
filteredRegressionsHtml model regressions =
  div
    [ class "filtered-select-field" ]
    [
       label
         []
         [ text "Filtered List" ]
     , select
         [ Form.onSelectChange UpdateSelectedElement ]
         (filteredRegressionList model regressions)
    ]


view : Model -> List Regression -> Html Msg
view model regressions =
  div
    [ class "regression-select" ]
    [
      div
        [ class "selectors" ]
        [
          (filterElementHtml model regressions "Projects" "project" UpdateProjectFilter)
        , (filterElementHtml model regressions "Run Types" "runType" UpdateRunTypeFilter)
        , (filterElementHtml model regressions "Users" "user" UpdateUserFilter)
        ]
    , (filteredRegressionsHtml model regressions)
    , p [] [ text model.selectedElement ]
    ]

