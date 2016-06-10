module ResultsTable exposing (..)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import List exposing (..)
import Set exposing (..)
import Dict exposing (..)
import Json.Decode as Json exposing (..)
import Debug exposing (..)

import RegressionData exposing (..)

type SortStatus = Unsorted | Ascending | Descending

type alias Column =
  {
    name : String
  , sortable : Bool
  , filterable : Bool
  , sortStatus : SortStatus
  , filters : Dict String Bool
  }

type alias Model =
  {
    data : List Simulation
  , columns : List Column
  , showFilterPane : Bool
  , itemBeingFiltered : String
  , checkBoxItems : Dict String Bool
  }

init : Model
init =
  {
    data = initialSimulations
  , columns = initColumns
  , showFilterPane = False
  , itemBeingFiltered = ""
  , checkBoxItems = Dict.empty
  }

initColumns : List Column
initColumns =
  [
    Column "#" True False Ascending Dict.empty
  , Column "Name" True False Unsorted Dict.empty
  --, Column "Config" True True Unsorted (Dict.insert "ddr" False Dict.empty)
  , Column "Config" True True Unsorted Dict.empty
  --, Column "Status" True True Unsorted Dict.empty
  , Column "Status" True True Unsorted (Dict.insert "Pass" False Dict.empty)
  , Column "Lsf Status" True True Unsorted Dict.empty
  , Column "Run Time" True False Unsorted Dict.empty
  ]

initialSimulations : List Simulation
initialSimulations =
  [  (Simulation 1 "simple_test" "default" "Pass" "Done" 1154)
  ,  (Simulation 2 "pcie_basic" "pcie"    "Pass" "Done" 912)
  ,  (Simulation 3 "wringout_test" "default" "Pass" "Done" 654)
  ,  (Simulation 4 "ddr_test" "ddr"     "Fail" "Exit" 543)
  ,  (Simulation 5 "random_test_1" "default" "Pass" "Done" 812)
  ,  (Simulation 6 "random_test_2" "default" "Pass" "Done" 83)
  ,  (Simulation 7 "pcie_advanced" "pcie"    "Fail" "Exit" 112)
  ,  (Simulation 8 "long_test" "default" "Fail" "Exit" 352)
  ,  (Simulation 9 "error_test" "default" "Error" "Exit" 352)
  ]

type Msg = NoOp
         | ProcessCheckBox AllCheckBoxData
         | Sort String
         | ShowFilterPane String
         | Filter

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    ProcessCheckBox value ->
      Debug.log (toString value)
      model ! []

    Sort field ->
      sortByField model field

    -- FIXME   Need to replace model.columns with a new definition.
    --         (which is in checkBoxItems)
    Filter ->
      { model | 
          showFilterPane = False,
          columns = model.columns
          -- FIXME - start here and build a new column we want to replace with
          --columns = modifyColumnList model.columns
          --  (Column "Config" True True Unsorted Dict.empty)
      }! []

    ShowFilterPane field ->
      { model 
          | showFilterPane = True,
            itemBeingFiltered = field,
            -- Merge the column filters with defaults
            checkBoxItems = Dict.union
              (columnFiltersFor model.columns field)
              (filterListElems model.data field)
      }! []

sortByField : Model -> String -> (Model, Cmd Msg) 
sortByField model field =
      case field of
        "Status" -> 
          { model | data = List.sortBy .status model.data } ! []

        "Lsf Status" -> 
          { model | data = List.sortBy .lsfStatus model.data } ! []

        "#" -> 
          { model | data = List.sortBy .runNum model.data } ! []

        "Config" -> 
          { model | data = List.sortBy .config model.data } ! []

        "Name" -> 
          { model | data = List.sortBy .name model.data } ! []

        "Run Time" -> 
          { model | data = List.sortBy .runTime model.data } ! []

        _ ->
          model ! []


uniquify : List comparable -> List comparable
uniquify list =
  list |> Set.fromList |> Set.toList 

listToDict : List String -> Dict String Bool
listToDict items =
  items
   |> uniquify
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
  List.map singleTableHeader columns


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
  List.map (\c -> td [] [ text (lookupDataValue simulation c.name) ]) columns

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

modalAttributes : Model -> List (Html.Attribute Msg)
modalAttributes model =
  if model.showFilterPane then
    [ class "filter-modal filter-visible" ]
  else
    [ class "filter-modal" ]

filterCheckBox : String -> Bool -> Html Msg
filterCheckBox name active =
  label 
    []
    [
      input 
      [ type' "checkbox", Attr.name name, Attr.checked active, onCheckboxChange ProcessCheckBox ]
      []
    , text name 
    ]

onCheckboxChange : (AllCheckBoxData -> msg) -> Attribute msg
onCheckboxChange tagger =
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

-- Return True if item is not in Dict (default to visible)
lookupMenuItem : Dict String Bool -> String -> Bool
lookupMenuItem items key =
  case Dict.get key items of
    Just a -> a
    Nothing -> True

checkBoxToHtml : Dict String Bool -> List (Html Msg)
checkBoxToHtml items =
  Dict.keys items |> List.map (\e -> (filterCheckBox e (lookupMenuItem items e)))

filterPane : Model -> Html Msg
filterPane model =
  div 
    (modalAttributes model)
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

------------------------------------------
-- These functions modify the filters 
-- for a particulatr column
modifyColumnList : List Column -> Column -> List Column
modifyColumnList columns newColumn =
  List.map (swapColumn newColumn) columns

swapColumn : Column -> Column -> Column
swapColumn column newColumn =
  if column.name == newColumn.name then
    newColumn
  else
    column

modifyColumnFilters : Column -> Dict String Bool -> Column
modifyColumnFilters column newFilters =
 { column | filters = newFilters }
------------------------------------------

view : Model -> Html Msg
view model =
  div
    []
    [
      (filterPane model)
    , table
        []
        (tableRows model)
    ]
