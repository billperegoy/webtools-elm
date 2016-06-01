module ResultsTable exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List exposing (..)

type SortStatus = Unsorted | Ascending | Descending

type alias Column =
  {
    name : String
    -- FIXME - this should be some sort of a function that is used to map
    --         from the Json data to a real value.
    --
    --, access : (? -> ?)
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
    header : HeaderRow
  , dataRows : List DataRow
  , columns : List Column
  } 

init : Model
init = 
  {
    header = HeaderRow
  , dataRows = []
  , columns = initColumns
  }

type alias HeaderRow =
 {
 }

type alias DataRow =
 {
 }

type Msg = NoOp

initColumns : List Column
initColumns =
  [
    Column "#" Ascending []
  , Column "Name" Unsorted []
  , Column "Config" Unsorted []
  , Column "Status" Unsorted []
  , Column "Lsf Status" Unsorted []
  , Column "Run Time" Unsorted []
  ]

view : Model -> Html Msg
view model =
  div 
    []
    [
      p [] [text "results table"], 
      table
        []
        [
        ]
    ]
