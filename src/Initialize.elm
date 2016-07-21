module Initialize exposing (..)

import Dict exposing (..)

import Api exposing (..)
import Summary exposing (..)
import ResultsTableData exposing (..)

initCompileColumns : List Column
initCompileColumns =
  [
    Column "Name" True True False Ascending Dict.empty
  , Column "Config" True True True Unsorted Dict.empty
  , Column "Status" True True True Unsorted Dict.empty
  , Column "Lsf Status" True True True Unsorted Dict.empty
  , Column "Run Time" True True False Unsorted Dict.empty
  ]

initLintColumns : List Column
initLintColumns =
  [
    Column "Name" True True False Ascending Dict.empty
  , Column "Status" True True True Unsorted Dict.empty
  , Column "Lsf Status" True True True Unsorted Dict.empty
  , Column "Run Time" True True False Unsorted Dict.empty
  ]

initSimColumns : List Column
initSimColumns =
  [
    Column "#" True True False Ascending Dict.empty
  , Column "Name" True True False Unsorted Dict.empty
  , Column "Config" True True True Unsorted Dict.empty
  , Column "Status" True True True Unsorted Dict.empty
  , Column "Lsf Status" True True True Unsorted Dict.empty
  , Column "Run Time" True True False Unsorted Dict.empty
  ]

initLsfInfo : LsfViewData
initLsfInfo =
  LsfViewData "1234" "Pass" "nrlnx23" 12345

initSummary : Summary
initSummary = 
  {
    regressionToolVersion = ""
  , runName = ""
  , project = ""
  , user = ""
  , site = ""
  , runType = ""
  , gvpLabel = Nothing
  , startDate = "" 
  , endDate = "" 
  , startDay = ""
  , lsfJobSuffix = ""
  , active  = True
  , timedOut = False
  , gvpMergeError = False
  , elapsedTime = Nothing
  , success = 0
  }
