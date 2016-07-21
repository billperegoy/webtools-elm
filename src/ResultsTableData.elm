module ResultsTableData exposing (..)

import Dict exposing (..)

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

