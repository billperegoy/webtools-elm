module ApiDataTypes exposing (..)

import Json.Decode as Json exposing (..)

apply : Json.Decoder (a -> b) -> Json.Decoder a -> Json.Decoder b
apply func value =
  Json.object2 (<|) func value

decodeStringList : Json.Decoder (List String)
decodeStringList =
  list Json.string

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
  , avgMem : Int
  , maxMem : Int
  , swap : Int
  , pids : String
  , submitTime : String
  , startTime : String
  , endTime : String
  , elapsedTime : Int
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
    ("avg_mem" := Json.int) `apply`
    ("max_mem" := Json.int) `apply`
    ("swap" := Json.int) `apply`
    ("pids" := Json.string) `apply`
    ("submit_time" := Json.string) `apply`
    ("start_time" := Json.string) `apply`
    ("end_time" := Json.string) `apply`
    ("elapsed_time" := Json.int)

type alias CompileApiData =
  {
    name : String
  , regressionName : String
  , projectName : String
  , compileType : String
  , config : String
  , lsfLogFile : String
  , executionLogFile : String
  , runCommand : String
  , runStatus : String
  , failSignatures : List String
  , lsfInfo : LsfInfo
  }

decodeCompileApiData : Json.Decoder CompileApiData 
decodeCompileApiData =
  Json.map CompileApiData 
    ("name" := Json.string) `apply`
    ("regressionName" := Json.string) `apply`
    ("projectName" := Json.string) `apply`
    ("compileType" := Json.string) `apply`
    ("config" := Json.string) `apply`
    ("lsfLogFile" := Json.string) `apply`
    ("executionLogFile" := Json.string) `apply`
    ("runCommand" := Json.string) `apply`
    ("runStatus" := Json.string) `apply`
    ("failSignatures" := decodeStringList) `apply`
    ("lsfInfo" := decodeLsfInfo)


type alias SimulationApiData =
  {
    name : String
  , baseName : String
  , regressionName : String
  , testId : Int
  , projectName : String
  , config : String
  , lsfLogFile : String
  , executionLogFile : String
  , runCommand : String
  , simArgs : String
  , runStatus : String
  , simTime : String
  , owner : String
  , seed : String
  , wordSize : Int
  , reservedMemory : Int
  , failSignatures : List String
  , lsfInfo : LsfInfo
  }

decodeSimulationApiData : Json.Decoder SimulationApiData
decodeSimulationApiData =
  Json.map SimulationApiData 
    ("name" := Json.string) `apply`
    ("baseName" := Json.string) `apply`
    ("regressionName" := Json.string) `apply`
    ("testId" := Json.int) `apply`
    ("projectName" := Json.string) `apply`
    ("config" := Json.string) `apply`
    ("lsfLogFile" := Json.string) `apply`
    ("executionLogFile" := Json.string) `apply`
    ("runCommand" := Json.string) `apply`
    ("simArgs" := Json.string) `apply`
    ("runStatus" := Json.string) `apply`
    ("simTime" := Json.string) `apply`
    ("owner" := Json.string) `apply`
    ("seed" := Json.string) `apply`
    ("wordSize" := Json.int) `apply`
    ("reservedMemory" := Json.int) `apply`
    ("failSignatures" := decodeStringList) `apply`
    ("lsfInfo" := decodeLsfInfo)

type alias LintApiData =
  {
    name : String
  , lintType : String
  , regressionName : String
  , projectName : String
  , lsfLogFile : String
  , executionLogFile : String
  , runStatus : String
  , lsfInfo : LsfInfo
  }

decodeLintApiData : Json.Decoder LintApiData
decodeLintApiData =
  Json.map LintApiData 
    ("name" := Json.string) `apply`
    ("lintType" := Json.string) `apply`
    ("regressionName" := Json.string) `apply`
    ("projectName" := Json.string) `apply`
    ("lsfLogFile" := Json.string) `apply`
    ("executionLogFile" := Json.string) `apply`
    ("runStatus" := Json.string) `apply`
    ("lsfInfo" := decodeLsfInfo)
