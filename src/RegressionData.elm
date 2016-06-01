module RegressionData exposing (..)

import Json.Decode as Json exposing (..)

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

type alias Simulation =
  {
    runNum : Int
  , name : String
  , config : String
  , status : String 
  , lsfStatus : String 
  , runTime : Int
  }
