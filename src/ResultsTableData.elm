module ResultsTableData exposing (..)

import Dict exposing (..)
import Summary exposing (..)

type SortStatus = Unsorted | Ascending | Descending

type alias Column =
  {
    name : String
  , visible : Bool
  , sortable : Bool
  , filterable : Bool
  , sortStatus : SortStatus
  , filters : Dict String Bool
  }

type alias Model =
  {
    resultsType : String
  , data : List Summary.SingleRun
  , columns : List Column
  , showEditColumnsPane : Bool
  , showFilterPane : Bool
  , itemBeingFiltered : String
  , columnFilterItems : Dict String Bool
  , columnVisibilityItems : Dict String Bool
  , sortField : String
  }
