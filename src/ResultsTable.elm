module ResultsTable exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List exposing (..)

import RegressionData exposing (..)

type SortStatus = Unsorted | Ascending | Descending

type alias Column =
  {
    name : String
    -- FIXME - this should be some sort of a function that is used to map
    --         from the Json data to a real value.
    --
    --, access : (? -> ?)
  , sortable : Bool
  , filterable : Bool
  , sortStatus : SortStatus
  , filters : List ColumnFilter
  }

-- Here an empty list will mean all visible
type alias ColumnFilter =
  {
    columnValue : String
  , visible : Bool
  }

type alias Model =
  {
    data : List Simulation
  , columns : List Column
  }

init : Model
init =
  {
    data = initialSimulations
  , columns = initColumns
  }

initColumns : List Column
initColumns =
  [
    Column "#" True False Ascending []
  , Column "Name" True False Unsorted []
  , Column "Config" True True Unsorted []
  , Column "Status" True True Unsorted []
  , Column "Lsf Status" True True Unsorted []
  , Column "Run Time" True False Unsorted []
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
         | Filter

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    -- FIXME - The sort is hard-coded to one field. How can I select what
    --         to sort by. I could use a case statement or make a
    --         separate Msg type for each field.
    --
    Sort field ->
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

    Filter ->
      model ! []

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
    img (tableIconAttributes Filter "images/glyphicons-321-filter.png") []
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

dataToTableRows :  Model -> List (Html Msg)
dataToTableRows model =
  List.map (singleDataTableRow model.columns) model.data

view : Model -> Html Msg
view model =
  div
    []
    [
      table
        []
        (tableRows model)
    ]
