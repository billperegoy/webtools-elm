module RegressionData exposing (..)

import Json.Decode as Json exposing (..)
import Dict exposing (..)
import ApiDataTypes exposing (..)

type SortStatus = Unsorted | Ascending | Descending

type alias LsfViewData =
  {
    jobId : String
  , status : String
  , execHost : String
  , elapsedTime : Int
  }

type alias SingleRun =
  {
    runNum : Int 
  , name : String
  , config : String
  , status : String
  , lsfInfo : LsfViewData
  }

type alias AllResults =
  {
    summary : ResultsTriad
  , compiles : List SingleRun
  , lints : List SingleRun
  , simulations : List SingleRun
  }

type alias SingleResult =
  {
    total : Int
  , complete : Int
  , failed : Int
  }

type alias RunTypeSummaryData =
  { label : String
  , result : SingleResult
  }

type alias ResultsTriad =
  { compiles : SingleResult
  , lints : SingleResult
  , sims : SingleResult
  }

decodeSingle : Json.Decoder SingleResult
decodeSingle =
  Json.object3 SingleResult
    ("total" := Json.int)
    ("complete" := Json.int)
    ("fail" := Json.int)

decodeAll : Json.Decoder ResultsTriad
decodeAll =
  Json.object3 ResultsTriad
    ("compiles" := decodeSingle)
    ("lints" := decodeSingle)
    ("sims" := decodeSingle)

{-
decodeSingleRun : Json.Decoder SingleRun
decodeSingleRun =
  Json.object6 SingleRun
    ("test_num" := Json.int)
    ("name" := Json.string)
    ("config" := Json.string)
    ("status" := Json.string)
    ("lsf_status" := Json.string)
    ("run_time" := Json.int)
-}


{-
decodeRunList : Json.Decoder (List SingleRun)
decodeRunList =
  list decodeSingleRun

decodeEverything : Json.Decoder AllResults
decodeEverything =
  Json.object4 AllResults 
    ("summary" := decodeAll)
    ("compiles" := decodeRunList)
    ("lints" := decodeRunList)
    ("simulations" := decodeRunList)
-}

type alias Regression =
  {
    name : String
  , project : String
  , runType : String 
  , user : String
  }

type alias Column =
  {
    name : String
  , visible : Bool
  , sortable : Bool
  , filterable : Bool
  , sortStatus : SortStatus
  , filters : Dict String Bool
  }
