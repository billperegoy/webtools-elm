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
  [  (Simulation 1 "test1" "default" Pass Done 1154)
  ,  (Simulation 2 "test2" "pcie"    Pass Done 912)
  ,  (Simulation 3 "test3" "default" Pass Done 654)
  ,  (Simulation 4 "test4" "ddr"     Fail Exit 543)
  ,  (Simulation 5 "test5" "default" Pass Done 812)
  ,  (Simulation 6 "test6" "default" Pass Done 83)
  ,  (Simulation 7 "test7" "pcie"    Fail Exit 112)
  ,  (Simulation 8 "test8" "default" Fail Exit 352)
  ]

type Msg = NoOp
         | Sort
         | Filter

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    Sort ->
      model ! []

    Filter ->
      model ! []


-- FIXME - Not sure if these are really things
type alias DataRow =
 {
 }

tableIconAttributes : String -> List (Attribute Msg)
tableIconAttributes file =
  [ class "table-header-icon", width 12, height 16, onClick Sort, src file ]

sortIcon : Column -> Html Msg
sortIcon column =
  if column.sortable then
    img (tableIconAttributes "images/glyphicons-405-sort-by-alphabet.png") []
  else
    span [] []

filterIcon : Column -> Html Msg
filterIcon column =
  if column.filterable then
    img (tableIconAttributes "images/glyphicons-321-filter.png") []
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

singleDataRowColumns : List Column -> List (Html Msg)
singleDataRowColumns columns =
  List.map (\c -> td [] [ text "xxx"]) columns

singleDataTableRow : List Column -> Simulation -> Html Msg
singleDataTableRow columns simulation =
  tr 
    [] 
    (singleDataRowColumns columns)

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