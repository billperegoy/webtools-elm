module Initialize exposing (..)

import Dict exposing (..)

import RegressionData exposing (..)

initRegressions : List Regression
initRegressions =
  [  (Regression "regression1" "project1" "validate" "user1")
  ,  (Regression "regression2" "project1" "publish" "user2")
  ,  (Regression "regression3" "project1" "validate" "user2")
  ,  (Regression "regression4" "project1" "validate" "user1")
  ,  (Regression "regression5" "project1" "validate" "user1")
  ,  (Regression "regression6" "project1" "publish" "user1")
  ,  (Regression "regression7" "project2" "publish" "user2")
  ,  (Regression "regression8" "project2" "validate" "user2")
  ,  (Regression "regression9" "project2" "validate" "user1")
  ,  (Regression "regression10" "project2" "validate" "user1")
  ,  (Regression "regression11" "project2" "publish" "user1")
  ,  (Regression "regression12" "project2" "regression" "user3")
  ]


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
