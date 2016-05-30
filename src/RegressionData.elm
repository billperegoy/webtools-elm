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

type RunStatus = Unknown | Pass | Fail | Error

runStatusToString : RunStatus -> String
runStatusToString runStatus =
  case runStatus of
    Pass -> "Pass"
    Fail -> "Fail"
    Error -> "Error"
    _ -> "-"

type LsfStatus = Unqueued | Pend | Run | Exit | Done

lsfStatusToString : LsfStatus -> String
lsfStatusToString lsfStatus =
  case lsfStatus of
    Unqueued -> "Unqueued"
    Pend -> "Pend"
    Run -> "Run"
    Exit -> "Exit"
    Done -> "Done"

type alias Simulation =
  {
    runNum : Int
  , name : String
  , config : String
  , status : RunStatus
  , lsfStatus : LsfStatus
  , runTime : Int
  }
