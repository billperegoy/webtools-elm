module ApiDataTypes exposing (..)

import Json.Decode as Json exposing (..)

apply : Json.Decoder (a -> b) -> Json.Decoder a -> Json.Decoder b
apply func value =
  Json.object2 (<|) func value

decodeStringList : Json.Decoder (List String)
decodeStringList =
  list Json.string

type alias RegressionApiData =
  {
    regerssionToolVersion : String
  , runName : String
  , project: String
  , user : String
  , site : String
  , runType : String
  , gvpLabel : String
  , startDate : String
  , endDate : String
  , startDay : String
  , lsfJobSuffix : String
  , active : Bool
  , timedOut : Bool
  , gvpMergeError : Bool
  , elapsedTime : Int
  , success : Int
  -- , gatherGroups
  -- , gvpMergeGroups
  -- , lntSummary
  -- , compileSummary
  -- , simSummary
  }

decodeRegressionApiData : Json.Decoder RegressionApiData
decodeRegressionApiData =
  Json.map RegressionApiData
    ("version" := Json.string) `apply`
    ("name" := Json.string) `apply`
    ("proj" := Json.string) `apply`
    ("user" := Json.string) `apply`
    ("site" := Json.string) `apply`
    ("run_type" := Json.string) `apply`
    ("gvp_label" := Json.string) `apply`
    ("start_date" := Json.string) `apply`
    ("end_date" := Json.string) `apply`
    ("start_day" := Json.string) `apply`
    ("lsf_job_suffix" := Json.string) `apply`
    ("active" := Json.bool) `apply`
    ("timedout" := Json.bool) `apply`
    ("gvpMergeError" := Json.bool) `apply`
    ("elapsedTime" := Json.int) `apply`
    ("success" := Json.int)

type alias LsfApiData =
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

decodeLsfApiData : Json.Decoder LsfApiData
decodeLsfApiData =
  Json.map LsfApiData
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
    (maybe ("elapsed_time" := Json.int))

type alias CompileApiData =
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
  , lsfInfo : LsfApiData
  }

decodeCompileApiList : Json.Decoder (List CompileApiData)
decodeCompileApiList =
  list decodeCompileApiData 

decodeCompileApiData : Json.Decoder CompileApiData
decodeCompileApiData =
  Json.map CompileApiData
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
    ("lsf_info" := decodeLsfApiData)


type alias SimulationApiData =
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
  , reservedMemory : Int
  , failSignatures : List String
  , lsfInfo : LsfApiData
  }

decodeSimulationApiList : Json.Decoder (List SimulationApiData)
decodeSimulationApiList =
  list decodeSimulationApiData 

decodeSimulationApiData : Json.Decoder SimulationApiData
decodeSimulationApiData =
  Json.map SimulationApiData
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
    ("reserved_mem" := Json.int) `apply`
    ("fail_signatures" := decodeStringList) `apply`
    ("lsf_info" := decodeLsfApiData)

type alias LintApiData =
  {
  -- FIXME   name : String
    lintType : String
  , regressionName : String
  , projectName : String
  , lsfLogFile : String
  , executionLogFile : String
  , runStatus : String
  , lsfInfo : LsfApiData
  }

decodeLintApiList : Json.Decoder (List LintApiData)
decodeLintApiList =
  list decodeLintApiData 

decodeLintApiData : Json.Decoder LintApiData
decodeLintApiData =
  Json.map LintApiData
    -- FIXME ("name" := Json.string) `apply`
    ("type" := Json.string) `apply`
    ("regr" := Json.string) `apply`
    ("proj" := Json.string) `apply`
    ("lsf_log" := Json.string) `apply`
    ("verilog_log" := Json.string) `apply`
    ("status" := Json.string) `apply`
    ("lsf_info" := decodeLsfApiData)

type alias TopApiData =
  {
    compiles : List CompileApiData
  , lints : List LintApiData
  , simulations : List SimulationApiData
  }

decodeTopApiData : Json.Decoder TopApiData
decodeTopApiData =
  Json.map TopApiData
    ("compiles" := decodeCompileApiList) `apply`
    ("lints" := decodeLintApiList) `apply`
    ("simulations" := decodeSimulationApiList)

