module ResultsTable exposing (..)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import List exposing (..)
import Set exposing (..)
import Dict exposing (..)
import Json.Decode as Json exposing (..)

import DictUtils exposing (getWithDefault)
import StringUtils exposing (uniquify)
import RegressionData exposing (..)
import Initialize exposing (..)
import Debug exposing (..)


type alias Model =
  {
    resultsType : String
  , data : List Simulation
  , columns : List Column
  , showEditColumnPane : Bool
  , showFilterPane : Bool
  , itemBeingFiltered : String
  , checkBoxItems : Dict String Bool
  }

init : String -> List Simulation -> Model
init resultsType data =
  {
    resultsType = resultsType
  , data = data 
  , showEditColumnPane = False
  , columns = Initialize.initColumns
  , showFilterPane = False
  , itemBeingFiltered = ""
  , checkBoxItems = Dict.empty
  }

type Msg = NoOp
         | Sort String
         | ShowFilterPane String
         | ProcessCheckBox AllCheckBoxData
         | ShowEditColumns
         | UpdateColumnVisibility
         | Filter
         | ClearAllFilters
         | UpdateData (List Simulation)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    UpdateData data ->
      Debug.log ("Updating data" ++ toString data)
      { model | data = data } ! []

    ProcessCheckBox item ->
      { model |
          checkBoxItems = updateCheckBoxItems model.checkBoxItems item
      } ! []

    Sort field ->
      { model |
          columns = setSortStatus model field
        , data = sortByField model.data field model.columns
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
            checkBoxItems = mergeFormCheckBoxItems model.columns model.data field
      } ! []

    ShowEditColumns ->
      model ! []

    UpdateColumnVisibility ->
      model ! []

    ClearAllFilters ->
      { model | columns = clearAllFilters model
      } ! []

mergeFormCheckBoxItems : List Column -> List Simulation -> String -> Dict String Bool
mergeFormCheckBoxItems columns data field =
  Dict.union
    (columnFiltersFor columns field)
    (filterListElems data field)

updateCheckBoxItems : Dict String Bool -> AllCheckBoxData -> Dict String Bool
updateCheckBoxItems checkBoxItems item =
  -- FIXME - really want to merge into existing Dict
  Dict.union
    (Dict.insert item.target.name item.target.checked Dict.empty)
    checkBoxItems

sortByField : List Simulation -> String -> List Column -> List Simulation
sortByField data field columns =
  let 
    direction = columnSortStatusFor columns field 
  in
    case field of
      "Status" -> 
        case direction of
          Descending -> List.sortBy .status data
          Ascending -> List.reverse (List.sortBy .status data)
          Unsorted -> List.sortBy .status data 

      "Lsf Status" -> 
        case direction of
          Descending -> List.sortBy .lsfStatus data
          Ascending -> List.reverse (List.sortBy .lsfStatus data)
          Unsorted -> List.sortBy .lsfStatus data 

      "#" -> 
        case direction of
          Descending -> List.sortBy .runNum data
          Ascending -> List.reverse (List.sortBy .runNum data)
          Unsorted -> List.sortBy .runNum data 

      "Config" -> 
        case direction of
          Descending -> List.sortBy .config data
          Ascending -> List.reverse (List.sortBy .config data)
          Unsorted -> List.sortBy .config data 

      "Name" -> 
        case direction of
          Descending -> List.sortBy .name data
          Ascending -> List.reverse (List.sortBy .name data)
          Unsorted -> List.sortBy .name data 

      "Run Time" -> 
        case direction of
          Descending -> List.sortBy .runTime data
          Ascending -> List.reverse (List.sortBy .runTime data)
          Unsorted -> List.sortBy .runTime data 

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
    case length filteredColumns of
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
    case length filteredColumns of
      1 -> 
        case head filteredColumns of
          Just a -> a.sortStatus
          Nothing -> Unsorted 
      _ -> Unsorted 


filterListElems : List Simulation -> String -> Dict String Bool
filterListElems data filterColumnName =
  case filterColumnName of
    "Config" -> (List.map .config data) |> listToDict
    "Status" -> (List.map .status data) |> listToDict
    "Lsf Status" -> (List.map .lsfStatus data) |> listToDict
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


tableRows : Model -> List (Html Msg)
tableRows model =
  (tableHeader model) :: (dataToTableRows model)

tableHeader : Model -> Html Msg
tableHeader model =
  tr
    []
    (columnsToTableHeader model.columns)

-- FIXME - can we do this in a less brute force way?
--
lookupDataValue : Simulation -> String -> String
lookupDataValue simulation name =
  case name of
    "#" -> toString simulation.runNum
    "Name" -> simulation.name
    "Config" -> simulation.config
    "Status" -> simulation.status
    "Lsf Status" -> simulation.lsfStatus
    "Run Time" -> toString simulation.runTime
    _ -> "-"

singleDataRowColumns : List Column -> Simulation -> List (Html Msg)
singleDataRowColumns columns simulation =
  List.filter (\c -> c.visible) columns
  |> List.map (\c -> td [] [ text (lookupDataValue simulation c.name) ])

singleDataTableRow : List Column -> Simulation -> Html Msg
singleDataTableRow columns simulation =
  tr
    []
    (singleDataRowColumns columns simulation)


-- Look up a value in the filter dictionary. If it's not there,
-- return True (visible)
--
findFilterBoolean : Dict comparable Bool -> comparable -> Bool
findFilterBoolean filters value =
  Maybe.withDefault True (Dict.get value filters)

columnFilterContainsValue : Column -> Simulation -> Bool
columnFilterContainsValue column simulation =
  let value =
    lookupDataValue simulation column.name
  in
    findFilterBoolean column.filters value

singleColumnToBoolean : Simulation -> Column -> Bool
singleColumnToBoolean simulation column =
  Dict.isEmpty column.filters || (columnFilterContainsValue column simulation)

columnsToBooleanList : List Column -> Simulation -> List Bool
columnsToBooleanList columns simulation=
  List.map (singleColumnToBoolean simulation) columns

columnFiltersReduce : List Bool -> Bool
columnFiltersReduce list =
  List.foldr (&&) True list

filterDataTableRow : List Column -> Simulation -> Bool
filterDataTableRow columns simulation =
  columnsToBooleanList columns simulation
  |> columnFiltersReduce

dataToTableRows :  Model -> List (Html Msg)
dataToTableRows model =
  List.filter (filterDataTableRow model.columns) model.data
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
      [ type' "checkbox", Attr.name name, Attr.checked active, onCheckBoxChange ProcessCheckBox ]
      []
    , text name 
    ]

onCheckBoxChange : (AllCheckBoxData -> msg) -> Attribute msg
onCheckBoxChange tagger =
  on "change" (Json.map tagger overallDecoder)

type alias AllCheckBoxData =
  {
    target : CheckBoxValue
  }

type alias CheckBoxValue =
  {
    name : String
  , checked : Bool
  }

overallDecoder : Json.Decoder AllCheckBoxData
overallDecoder =
  object1 AllCheckBoxData
    ("target" := checkBoxDecoder) 

checkBoxDecoder : Json.Decoder CheckBoxValue
checkBoxDecoder =
  object2 CheckBoxValue
    ("name" := string)
    ("checked" := bool)

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
      (checkBoxToHtml model.checkBoxItems)
    , button
        [ onClick Filter ]
        [ text "Filter" ]
    ]

editColumnsPane : Model -> Html Msg
editColumnsPane model =
  div
    []
    [ 
      text "Edit Columns"
    , button
        [] 
        [ text "Submit" ]
    ]

------------------------------------------
-- These functions modify the filters 
-- for a particulatr column
modifyColumnList : Model -> List Column
modifyColumnList model =
  replaceFiltersOnColumn model.columns model.itemBeingFiltered model.checkBoxItems

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
    [  ]
    [ text "Edit Columns" ]

view : Model -> Html Msg
view model =
  div
    []
    [
      (filterPane model)
    , (editColumnsPane model)
    , h1 [] [ text model.resultsType ]
    , clearFiltersButton
    , editColumnsButton
    , table
        []
        (tableRows model)
    ]
