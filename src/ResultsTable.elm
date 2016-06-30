module ResultsTable exposing (..)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import List exposing (..)
import Set exposing (..)
import Dict exposing (..)
import Json.Decode as Json exposing (..)
import String exposing (..)

import DictUtils exposing (getWithDefault)
import StringUtils exposing (uniquify)
import FormUtils as Form exposing (..)
import RegressionData exposing (..)
import Initialize exposing (..)


type alias Model =
  {
    resultsType : String
  , data : List SingleRun
  , columns : List Column
  , showEditColumnsPane : Bool
  , showFilterPane : Bool
  , itemBeingFiltered : String
  , columnFilterItems : Dict String Bool
  , columnVisibilityItems : Dict String Bool
  , sortField : String
  }

init : String -> List Column -> List SingleRun -> Model
init resultsType columns data =
  {
    resultsType = resultsType
  , data = data
  , showEditColumnsPane = False
  , columns = columns
  , showFilterPane = False
  , itemBeingFiltered = ""
  , columnFilterItems = Dict.empty
  , columnVisibilityItems = Dict.empty
  , sortField = "#"
  }

type Msg = NoOp
         | Sort String
         | ShowFilterPane String
         | ProcessFilterCheckBox Form.CheckBoxData
         | ShowColumnVisibilityPane
         | ProcessColumnVisibilityCheckBox Form.CheckBoxData
         | UpdateColumnVisibility
         | Filter
         | ClearAllFilters

update : Msg -> Model -> List SingleRun -> (Model, Cmd Msg)
update msg model data =
  case msg of
    NoOp ->
      model ! []

    ProcessFilterCheckBox item ->
      { model |
          columnFilterItems = updateColumnFilterItems model.columnFilterItems item
      } ! []

    Sort field ->
      { model |
          columns = setSortStatus model field
        , sortField = field
      } ! []

    Filter ->
      { model |
          showFilterPane = False,
          columns = modifyColumnList model
      } ! []

    ShowFilterPane field ->
      { model
          | showFilterPane = True,
            itemBeingFiltered = field,
            columnFilterItems = mergeFormCheckBoxItems model.columns data field
      } ! []

    ShowColumnVisibilityPane ->
      { model |
          showEditColumnsPane = True
        , columnVisibilityItems = setInitialColumnVisibility model
      } ! []

    ProcessColumnVisibilityCheckBox item ->
      { model | columnVisibilityItems = updateColumnVisibilityItems model.columnVisibilityItems item
      } ! []

    UpdateColumnVisibility ->
      -- FIXME here we transfer the new visibility values to the column
      { model |
          showEditColumnsPane = False
        , columns = updateColumnVisibilityFromForm model
      } ! []

    ClearAllFilters ->
      { model | columns = clearAllFilters model
      } ! []

mergeFormCheckBoxItems : List Column -> List SingleRun -> String -> Dict String Bool
mergeFormCheckBoxItems columns data field =
  Dict.union
    (columnFiltersFor columns field)
    (filterListElems data field)

updateColumnFilterItems : Dict String Bool -> Form.CheckBoxData -> Dict String Bool
updateColumnFilterItems columnFilterItems item =
  Dict.union
    (Dict.insert item.target.name item.target.checked Dict.empty)
    columnFilterItems

sortByField : List SingleRun -> String -> List Column -> List SingleRun
sortByField data field columns =
  let
    direction = columnSortStatusFor columns field
  in
    case field of
      "Status" ->
        case direction of
          Ascending -> List.sortBy .status data
          Descending -> List.reverse (List.sortBy .status data)
          Unsorted -> List.sortBy .status data

      "Lsf Status" ->
        case direction of
          Ascending -> List.sortBy (\e -> e.lsfInfo.status) data
          Descending -> List.reverse (List.sortBy (\e -> e.lsfInfo.status) data)
          Unsorted -> List.sortBy (\e -> e.lsfInfo.status) data

      "#" ->
        case direction of
          Ascending -> List.sortBy .runNum data
          Descending -> List.reverse (List.sortBy .runNum data)
          Unsorted -> List.sortBy .runNum data

      "Config" ->
        case direction of
          Ascending -> List.sortBy .config data
          Descending -> List.reverse (List.sortBy .config data)
          Unsorted -> List.sortBy .config data

      "Name" ->
        case direction of
          Ascending -> List.sortBy .name data
          Descending -> List.reverse (List.sortBy .name data)
          Unsorted -> List.sortBy .name data

      "Run Time" ->
        case direction of
          Ascending -> List.sortBy (\e -> e.lsfInfo.elapsedTime) data
          Descending -> List.reverse (List.sortBy (\e -> e.lsfInfo.elapsedTime) data)
          Unsorted -> List.sortBy (\e -> e.lsfInfo.elapsedTime) data

      _ ->
        data


listToDict : List String -> Dict String Bool
listToDict items =
  items
   |> StringUtils.uniquify
   -- FIXME - This looks to be the broken thing. This always sets things to True?
   |> List.foldl (\item -> Dict.insert item True) Dict.empty

columnFiltersFor : List Column -> String -> Dict String Bool
columnFiltersFor columns columnName =
  let
    filteredColumns = List.filter (\column -> (column.name == columnName)) columns
  in
    case List.length filteredColumns of
      1 ->
        case head filteredColumns of
          Just a -> a.filters
          Nothing -> Dict.empty
      _ -> Dict.empty

columnSortStatusFor : List Column -> String -> SortStatus
columnSortStatusFor columns columnName =
  let
    filteredColumns = List.filter (\column -> (column.name == columnName)) columns
  in
    case List.length filteredColumns of
      1 ->
        case head filteredColumns of
          Just a -> a.sortStatus
          Nothing -> Unsorted
      _ -> Unsorted


filterListElems : List SingleRun -> String -> Dict String Bool
filterListElems data filterColumnName =
  case filterColumnName of
    "Config" -> (List.map .config data) |> listToDict
    "Status" -> (List.map .status data) |> listToDict
    "Lsf Status" -> (List.map .lsfInfo data) |> (List.map .status) |> listToDict
    _ -> Dict.empty

tableIconAttributes : Msg -> String -> List (Attribute Msg)
tableIconAttributes msg file =
  [ class "table-header-icon", width 12, height 16, onClick msg, src file ]

sortPng : String
sortPng = "images/glyphicons-404-sorting.png"

filterPng : String
filterPng = "images/glyphicons-321-filter.png"

sortIcon : Column -> Html Msg
sortIcon column =
  if column.sortable then
    img (tableIconAttributes (Sort column.name) sortPng) []
  else
    span [] []

filterIcon : Column -> Html Msg
filterIcon column =
  if column.filterable then
    img (tableIconAttributes (ShowFilterPane column.name) filterPng) []
  else
    span [] []

singleTableHeader : Column -> Html Msg
singleTableHeader column =
  th
    []
    [
      text column.name
    , (sortIcon column)
    , (filterIcon column)
    ]

columnsToTableHeader : List Column -> List (Html Msg)
columnsToTableHeader columns =
  List.filter (\c -> c.visible) columns
  |> List.map singleTableHeader


tableRows : Model -> List SingleRun -> List (Html Msg)
tableRows model data =
  (tableHeader model) :: (dataToTableRows model data)

tableHeader : Model -> Html Msg
tableHeader model =
  tr
    []
    (columnsToTableHeader model.columns)

-- FIXME - can we do this in a less brute force way?
--
lookupDataValue : SingleRun -> String -> String
lookupDataValue job name =
  case name of
    "#" -> toString job.runNum
    "Name" -> job.name
    "Config" -> job.config
    "Status" -> job.status
    "Lsf Status" -> job.lsfInfo.status
    "Run Time" -> toString job.lsfInfo.elapsedTime
    _ -> "-"

singleDataRowColumns : List Column -> SingleRun -> List (Html Msg)
singleDataRowColumns columns job =
  List.filter (\c -> c.visible) columns
  |> List.map (\c -> td [] [ text (lookupDataValue job c.name) ])

singleTableRowAttributes data =
  let
    status = lookupDataValue data "Status"
    lsfStatus = lookupDataValue data "Lsf Status"
  in
    if ((String.toLower status) == "Fail") || ((String.toLower status) == "Error")  then
      [ class "job-fail" ]
    else if (String.toLower lsfStatus) == "run" then
      [ class "job-run" ]
    else if (String.toLower status) == "pass" then
      [ class "job-pass" ]
    else if (String.toLower lsfStatus) == "pend" then
      [ class "job-pend" ]
    else
      []

singleDataTableRow : List Column -> SingleRun -> Html Msg
singleDataTableRow columns job =
  tr
    (singleTableRowAttributes job)
    (singleDataRowColumns columns job)


-- Look up a value in the filter dictionary. If it's not there,
-- return True (visible)
--
findFilterBoolean : Dict comparable Bool -> comparable -> Bool
findFilterBoolean filters value =
  Maybe.withDefault True (Dict.get value filters)

columnFilterContainsValue : Column -> SingleRun -> Bool
columnFilterContainsValue column job =
  let value =
    lookupDataValue job column.name
  in
    findFilterBoolean column.filters value

singleColumnToBoolean : SingleRun -> Column -> Bool
singleColumnToBoolean job column =
  Dict.isEmpty column.filters || (columnFilterContainsValue column job)

columnsToBooleanList : List Column -> SingleRun -> List Bool
columnsToBooleanList columns job =
  List.map (singleColumnToBoolean job) columns

columnFiltersReduce : List Bool -> Bool
columnFiltersReduce list =
  List.foldr (&&) True list

filterDataTableRow : List Column -> SingleRun -> Bool
filterDataTableRow columns job =
  columnsToBooleanList columns job
  |> columnFiltersReduce

dataToTableRows :  Model -> List SingleRun -> List (Html Msg)
dataToTableRows model data =
  sortByField data model.sortField model.columns
  |> List.filter (filterDataTableRow model.columns)
  |> List.map (singleDataTableRow model.columns)

filterPaneAttributes : Model -> List (Html.Attribute Msg)
filterPaneAttributes model =
  if model.showFilterPane then
    [ class "filter-modal filter-visible" ]
  else
    [ class "filter-modal" ]

filterPaneCheckBox : String -> Bool -> Html Msg
filterPaneCheckBox name active =
  label
    []
    [
      input
      [ type' "checkbox", Attr.name name, Attr.checked active, Form.onCheckBoxChange ProcessFilterCheckBox ]
      []
    , text name
    ]

checkBoxToHtml : Dict String Bool -> List (Html Msg)
checkBoxToHtml items =
  Dict.keys items |> List.map (\e -> (filterPaneCheckBox e (DictUtils.getWithDefault items e True)))

filterPane : Model -> Html Msg
filterPane model =
  div
    (filterPaneAttributes model)
    [
      div
        []
        [ text ("Filtering: " ++ model.itemBeingFiltered) ]
    , div
      []
      (checkBoxToHtml model.columnFilterItems)
    , button
        [ onClick Filter ]
        [ text "Filter" ]
    ]

-------------------------------------------
-- This code is all associated with editng the column visibility
editColumnsPane : Model -> Html Msg
editColumnsPane model =
  div
    (editColumnsPaneAttributes model)
    [
      div
        []
        (editColumnsPaneCheckBoxes model)
    , button
        [ onClick UpdateColumnVisibility ]
        [ text "Submit" ]
    ]

editColumnsPaneCheckBoxes : Model -> List (Html Msg)
editColumnsPaneCheckBoxes model =
  List.map editColumnsPaneCheckBox model.columns

editColumnsPaneCheckBox : Column -> Html Msg
editColumnsPaneCheckBox column =
  label
    [ Form.onCheckBoxChange ProcessColumnVisibilityCheckBox ]
    [
      input
      [ type' "checkbox", Attr.name column.name, Attr.checked column.visible ]
      []
    , text column.name
    ]

editColumnsPaneAttributes : Model -> List (Html.Attribute Msg)
editColumnsPaneAttributes model =
  if model.showEditColumnsPane then
    [ class "edit-columns-pane edit-columns-visible" ]
  else
    [ class "edit-columns-pane" ]

setInitialColumnVisibility : Model -> Dict String Bool
setInitialColumnVisibility model =
  List.foldl (\item -> Dict.insert item.name item.visible) Dict.empty model.columns

updateColumnVisibilityFromForm : Model -> List Column
updateColumnVisibilityFromForm model =
  List.map (\column -> { column | visible = (getNewColumnVisibility model.columnVisibilityItems column.name) } ) model.columns

getNewColumnVisibility : Dict String Bool -> String -> Bool
getNewColumnVisibility items columnName =
  DictUtils.getWithDefault items columnName True
-------------------------------------------




------------------------------------------
-- These functions modify the filters
-- for a particulatr column
modifyColumnList : Model -> List Column
modifyColumnList model =
  replaceFiltersOnColumn model.columns model.itemBeingFiltered model.columnFilterItems

clearAllFilters : Model -> List Column
clearAllFilters model =
  List.map (modifyColumnFilters Dict.empty) model.columns

-- Map over all of the colums and swap the filters only on the matching one
replaceFiltersOnColumn : List Column -> String -> Dict String Bool -> List Column
replaceFiltersOnColumn columns columnName newFilters =
  List.map (swapColumn columnName newFilters) columns

-- Note that the elements being mapped over comes last in the arg list - I
-- always forget that
swapColumn : String -> Dict String Bool -> Column -> Column
swapColumn columnName newFilters column =
  if column.name == columnName then
    modifyColumnFilters newFilters column
  else
    column

modifyColumnFilters : Dict String Bool -> Column -> Column
modifyColumnFilters newFilters column =
 { column | filters = newFilters }

updateColumnVisibilityItems : Dict String Bool -> Form.CheckBoxData -> Dict String Bool
updateColumnVisibilityItems columnVisibilityItems item =
  Dict.insert item.target.name item.target.checked columnVisibilityItems


------------------------------------------

flipSortStatus : SortStatus -> SortStatus
flipSortStatus status =
  case status of
    Ascending -> Descending
    Descending -> Ascending
    Unsorted -> Ascending

updateOneSortStatus : String -> Column -> Column
updateOneSortStatus name column =
  if column.name == name then
    { column | sortStatus = flipSortStatus column.sortStatus }
  else
    { column | sortStatus = Unsorted }


setSortStatus : Model -> String -> List Column
setSortStatus model name =
  List.map (updateOneSortStatus name) model.columns

clearFiltersButton : Html Msg
clearFiltersButton =
  button
    [ onClick ClearAllFilters ]
    [ text "Clear Filters" ]

editColumnsButton : Html Msg
editColumnsButton =
  button
    [ onClick ShowColumnVisibilityPane ]
    [ text "Edit Columns" ]

view : Model -> List SingleRun -> Html Msg
view model data =
  div
    [ class "results-table" ]
    [
      h1 [] [ text model.resultsType ]
    , (filterPane model)
    , (editColumnsPane model)
    , clearFiltersButton
    , editColumnsButton
    , table
        []
        (tableRows model data)
    ]
