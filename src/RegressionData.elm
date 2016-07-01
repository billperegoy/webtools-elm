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

type alias Regression =
  {
    name : String
  , project : String
  , runType : String 
  , user : String
  }

decodeRegression : Json.Decoder Regression
decodeRegression =
  Json.object4 Regression
    ("name" := Json.string)
    ("proj" := Json.string)
    ("run_type" := Json.string)
    ("user" := Json.string)


decodeRegressionList : Json.Decoder (List Regression)
decodeRegressionList =
  list decodeRegression 

type alias Column =
  {
    name : String
  , visible : Bool
  , sortable : Bool
  , filterable : Bool
  , sortStatus : SortStatus
  , filters : Dict String Bool
  }
