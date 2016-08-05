module ResultsTableData exposing (..)

import Dict exposing (..)
import ViewData exposing (..)

type SortStatus = Unsorted | Ascending | Descending

type alias Column =
  {
    name : String
  , visible : Bool
  , sortable : Bool
  , filterable : Bool
  , sortStatus : SortStatus
  , filters : Dict String Bool
  , displayFunction : (SingleRun -> String)
  , sortFunction : (List SingleRun -> List SingleRun)
  
  }

