module RegressionData exposing (..)

import Dict exposing (..)

type SortStatus = Unsorted | Ascending | Descending


{--
type alias SingleRun =
  {
    runNum : Int
  , name : String
  , config : String
  , status : String
  , lsfInfo : LsfViewData
  }
--}

type alias Column =
  {
    name : String
  , visible : Bool
  , sortable : Bool
  , filterable : Bool
  , sortStatus : SortStatus
  , filters : Dict String Bool
  }
