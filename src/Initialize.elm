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


initColumns : List Column
initColumns =
  [
    Column "#" True True False Ascending Dict.empty
  , Column "Name" True True False Unsorted Dict.empty
  , Column "Config" True True True Unsorted Dict.empty
  , Column "Status" True True True Unsorted Dict.empty
  , Column "Lsf Status" True True True Unsorted Dict.empty
  , Column "Run Time" True True False Unsorted Dict.empty
  ]

initSimulations : List SingleRun 
initSimulations =
  [  (SingleRun 1 "simple_test" "default" "Pass" "Done" 1154)
  ,  (SingleRun 2 "pcie_basic" "pcie"    "Pass" "Done" 912)
  ,  (SingleRun 3 "wringout_test" "default" "Pass" "Done" 654)
  ,  (SingleRun 4 "ddr_test" "ddr" "-" "Run" 543)
  ,  (SingleRun 5 "random_test_1" "default" "Pass" "Done" 812)
  ,  (SingleRun 6 "random_test_2" "default" "-" "Pend" 83)
  ,  (SingleRun 7 "pcie_advanced" "pcie"    "Fail" "Exit" 112)
  ,  (SingleRun 8 "long_test" "default" "Fail" "Exit" 352)
  ,  (SingleRun 9 "error_test" "default" "Error" "Exit" 352)
  ]

initCompiles : List SingleRun
initCompiles =
  [  (SingleRun 1 "simple_test" "default" "Pass" "Done" 1154)
  ,  (SingleRun 2 "pcie_basic" "pcie"    "Pass" "Done" 912)
  ,  (SingleRun 3 "wringout_test" "default" "Pass" "Done" 654)
  ]

initLints : List SingleRun
initLints =
  [  (SingleRun 1 "simple_test" "default" "Pass" "Done" 1154)
  ]
