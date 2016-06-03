module ResultsTable exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List exposing (..)
import Dict exposing (..)

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
  }

init : Model
init =
  {
    data = initialSimulations
  , columns = initColumns
  , showFilterPane = False
  }

initColumns : List Column
initColumns =
  [
    Column "#" True False Ascending Dict.empty
  , Column "Name" True False Unsorted Dict.empty
  , Column "Config" True True Unsorted (Dict.insert "ddr" False Dict.empty)
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
  ]

type Msg = NoOp
         | Sort String
         | ShowFilterPane String
         | Filter


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

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    Sort field ->
      sortByField model field

    Filter ->
      { model | showFilterPane = False }! []

    ShowFilterPane field ->
      { model | showFilterPane = True }! []

tableIconAttributes : Msg -> String -> List (Attribute Msg)
tableIconAttributes msg file =
  [ class "table-header-icon", width 12, height 16, onClick msg, src file ]

sortIcon : Column -> Html Msg
sortIcon column =
  if column.sortable then
    img (tableIconAttributes (Sort column.name) "images/glyphicons-404-sorting.png") []
  else
    span [] []

filterIcon : Column -> Html Msg
filterIcon column =
  if column.filterable then
    img (tableIconAttributes (ShowFilterPane column.name) "images/glyphicons-321-filter.png") []
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
-- FIXME - not sure why I need to use this more general type 
--         definition. I don't see any way this can be anything 
--         but Dict String
--findFilterBoolean : Dict String -> String -> Bool
findFilterBoolean : Dict comparable Bool -> comparable -> Bool
findFilterBoolean filters value =
  case Dict.get value filters of
    Just result -> result
    Nothing -> True

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

filterPane : Model -> Html Msg
filterPane model =
  div 
    (modalAttributes model)
    [ text "Put text modal here" 
    , button
        [ onClick Filter ]
        [ text "Filter" ]
    ]

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
