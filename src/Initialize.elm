module Initialize exposing (..)

import Dict exposing (..)

import Api exposing (..)
import Summary exposing (..)
import RegressionData exposing (..)

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

initSimulations : List SingleRun 
initSimulations =
  [  (SingleRun 1 "simple_test" "default" "Pass" initLsfInfo)
  ,  (SingleRun 2 "pcie_basic" "pcie"    "Pass" initLsfInfo)
  ,  (SingleRun 3 "wringout_test" "default" "Pass" initLsfInfo)
  ,  (SingleRun 4 "ddr_test" "ddr" "-" initLsfInfo)
  ,  (SingleRun 5 "random_test_1" "default" "Pass" initLsfInfo)
  ,  (SingleRun 6 "random_test_2" "default" "-" initLsfInfo)
  ,  (SingleRun 7 "pcie_advanced" "pcie"    "Fail" initLsfInfo)
  ,  (SingleRun 8 "long_test" "default" "Fail" initLsfInfo)
  ,  (SingleRun 9 "error_test" "default" "Error" initLsfInfo)
  ]

initCompiles : List SingleRun
initCompiles =
  [  (SingleRun 1 "simple_test" "default" "Pass" initLsfInfo)
  ,  (SingleRun 2 "pcie_basic" "pcie"    "Pass" initLsfInfo)
  ,  (SingleRun 3 "wringout_test" "default" "Pass" initLsfInfo)
  ]

initLints : List SingleRun
initLints =
  [  (SingleRun 1 "simple_test" "default" "Pass" initLsfInfo)
  ]

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
