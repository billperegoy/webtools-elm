module Api exposing (..)

import Json.Decode as Json exposing (..)

apply : Json.Decoder (a -> b) -> Json.Decoder a -> Json.Decoder b
apply func value =
  Json.object2 (<|) func value

decodeStringList : Json.Decoder (List String)
decodeStringList =
  list Json.string

type alias Summary =
  {
    regressionToolVersion : String
  , runName : String
  , project: String
  , user : String
  , site : String
  , runType : String
  , gvpLabel : Maybe String
  , startDate : String
  , endDate : String
  , startDay : String
  , lsfJobSuffix : String
  , active : Bool
  , timedOut : Bool
  , gvpMergeError : Bool
  , elapsedTime : Maybe Float
  , success : Int
  -- , gatherGroups
  -- , gvpMergeGroups
  -- , lntSummary
  -- , compileSummary
  -- , simSummary
  }

decodeSummary : Json.Decoder Summary
decodeSummary =
  Json.map Summary
    ("version" := Json.string) `apply`
    ("name" := Json.string) `apply`
    ("proj" := Json.string) `apply`
    ("user" := Json.string) `apply`
    ("site" := Json.string) `apply`
    ("run_type" := Json.string) `apply`
    (maybe("gvp_label" := Json.string)) `apply`
    ("start_date" := Json.string) `apply`
    ("end_date" := Json.string) `apply`
    ("start_day" := Json.string) `apply`
    ("lsf_job_suffix" := Json.string) `apply`
    ("active" := Json.bool) `apply`
    ("timed_out" := Json.bool) `apply`
    ("gvp_merge_error" := Json.bool) `apply`
    (maybe("elapsed_time" := Json.float)) `apply`
    ("success" := Json.int)

type alias LsfInfo =
  {
    jobId : String
  , runName : String
  , userName : String
  , projectName : String
  , status : String
  , queue : String
  , submitHost : String
  , execHost : String
  , cpu : Float
  , avgMem : Maybe Int
  , maxMem : Maybe Int
  , swap : Int
  , pids : String
  , submitTime : String
  , startTime : Maybe String
  , endTime : Maybe String
  , elapsedTime : Maybe Int
  }

decodeLsfInfo : Json.Decoder LsfInfo
decodeLsfInfo =
  Json.map LsfInfo
    ("jid" := Json.string) `apply`
    ("name" := Json.string) `apply`
    ("user" := Json.string) `apply`
    ("project" := Json.string) `apply`
    ("status" := Json.string) `apply`
    ("queue" := Json.string) `apply`
    ("submit_host" := Json.string) `apply`
    ("exec_host" := Json.string) `apply`
    ("cpu" := Json.float) `apply`
    (maybe ("avg_mem" := Json.int)) `apply`
    (maybe ("max_mem" := Json.int)) `apply`
    ("swap" := Json.int) `apply`
    ("pids" := Json.string) `apply`
    ("submit_time" := Json.string) `apply`
    (maybe ("start_time" := Json.string)) `apply`
    (maybe ("end_time" := Json.string)) `apply`
    (maybe("elapsed_time" := Json.int))

type alias Compile =
  {
    name : String
  , regressionName : String
  , projectName : String
  , compileType : String
  , config : String
  , lsfLogFile : String
  , executionLogFile : Maybe String
  , runCommand : String
  , runStatus : String
  , failSignatures : List String
  , lsfInfo : LsfInfo
  }

decodeCompileList : Json.Decoder (List Compile)
decodeCompileList =
  list decodeCompile 

decodeCompile : Json.Decoder Compile
decodeCompile =
  Json.map Compile
    ("name" := Json.string) `apply`
    ("regr" := Json.string) `apply`
    ("proj" := Json.string) `apply`
    ("type" := Json.string) `apply`
    ("config" := Json.string) `apply`
    ("lsf_log" := Json.string) `apply`
    (maybe ("verilog_log" := Json.string)) `apply`
    ("sim_lsf_cmd" := Json.string) `apply`
    ("status" := Json.string) `apply`
    ("fail_signatures" := decodeStringList) `apply`
    ("lsf_info" := decodeLsfInfo)


type alias Simulation =
  {
    name : String
  , baseName : String
  , regressionName : String
  , testId : Int
  , projectName : String
  , config : String
  , lsfLogFile : String
  , executionLogFile : Maybe String
  , runCommand : Maybe String
  , simArgs : String
  , runStatus : String
  , simTime : Maybe String
  , owner : Maybe String
  , seed : String 
  , wordSize : Int
  , reservedMemory : Maybe Int
  , failSignatures : List String
  , lsfInfo : LsfInfo
  }

decodeSimulationList : Json.Decoder (List Simulation)
decodeSimulationList =
  list decodeSimulation 

decodeSimulation : Json.Decoder Simulation
decodeSimulation =
  Json.map Simulation
    ("name" := Json.string) `apply`
    ("test_basename" := Json.string) `apply`
    ("regr" := Json.string) `apply`
    ("test_num" := Json.int) `apply`
    ("proj" := Json.string) `apply`
    ("config" := Json.string) `apply`
    ("lsf_log" := Json.string) `apply`
    (maybe ("verilog_log" := Json.string)) `apply`
    (maybe ("sim_lsf_cmd" := Json.string)) `apply`
    ("sim_args" := Json.string) `apply`
    ("status" := Json.string) `apply`
    (maybe ("sim_time" := Json.string)) `apply`
    (maybe ("owner" := Json.string)) `apply`
    ("seed" := Json.string) `apply`
    ("word_size" := Json.int) `apply`
    (maybe("reserved_mem" := Json.int)) `apply`
    ("fail_signatures" := decodeStringList) `apply`
    ("lsf_info" := decodeLsfInfo)

type alias Lint =
  {
  -- FIXME   name : String
    lintType : String
  , regressionName : String
  , projectName : String
  , lsfLogFile : String
  -- FIXME , executionLogFile : String
  , runStatus : Maybe String
  , lsfInfo : LsfInfo
  }

decodeLintList : Json.Decoder (List Lint)
decodeLintList =
  list decodeLint 

decodeLint : Json.Decoder Lint
decodeLint =
  Json.map Lint
    -- FIXME ("name" := Json.string) `apply`
    ("type" := Json.string) `apply`
    ("regr" := Json.string) `apply`
    ("proj" := Json.string) `apply`
    ("lsf_log" := Json.string) `apply`
    -- FIXME ("verilog_log" := Json.string) `apply`
    (maybe("status" := Json.string)) `apply`
    ("lsf_info" := decodeLsfInfo)

type alias Data =
  {
    summary : Summary
  , compiles : List Compile
  , lints : List Lint
  , simulations : List Simulation
  }

decodeData : Json.Decoder Data
decodeData =
  Json.map Data
    ("summary" := decodeSummary) `apply`
    ("compiles" := decodeCompileList) `apply`
    ("lints" := decodeLintList) `apply`
    ("simulations" := decodeSimulationList)






