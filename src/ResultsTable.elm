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


type alias Model =
  {
    resultsType : String
  , data : List Simulation
  , columns : List Column
  , showFilterPane : Bool
  , itemBeingFiltered : String
  , checkBoxItems : Dict String Bool
  }

init : String -> Model
init resultsType =
  {
    resultsType = resultsType
  , data = Initialize.initSimulations
  , columns = Initialize.initColumns
  , showFilterPane = False
  , itemBeingFiltered = ""
  , checkBoxItems = Dict.empty
  }

type Msg = NoOp
         | ProcessCheckBox AllCheckBoxData
         | Sort String
         | ShowFilterPane String
         | Filter
         | ClearAllFilters

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    ProcessCheckBox item ->
      { model |
          checkBoxItems = updateCheckBoxItems model.checkBoxItems item
      } ! []

    Sort field ->
      sortByField model field

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

clearFiltersButton : Html Msg
clearFiltersButton =
  button
    [ onClick ClearAllFilters ]
    [ text "Clear Filters" ]

view : Model -> Html Msg
view model =
  div
    []
    [
      (filterPane model)
    , h1 [] [ text model.resultsType ]
    , clearFiltersButton
    , table
        []
        (tableRows model)
    ]
