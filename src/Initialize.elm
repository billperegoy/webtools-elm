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
    Column "#" True False Ascending Dict.empty
  , Column "Name" True False Unsorted Dict.empty
  , Column "Config" True True Unsorted Dict.empty
  , Column "Status" True True Unsorted Dict.empty
  , Column "Lsf Status" True True Unsorted Dict.empty
  , Column "Run Time" True False Unsorted Dict.empty
  ]

initSimulations : List Simulation
initSimulations =
  [  (Simulation 1 "simple_test" "default" "Pass" "Done" 1154)
  ,  (Simulation 2 "pcie_basic" "pcie"    "Pass" "Done" 912)
  ,  (Simulation 3 "wringout_test" "default" "Pass" "Done" 654)
  ,  (Simulation 4 "ddr_test" "ddr"     "Fail" "Exit" 543)
  ,  (Simulation 5 "random_test_1" "default" "Pass" "Done" 812)
  ,  (Simulation 6 "random_test_2" "default" "Pass" "Done" 83)
  ,  (Simulation 7 "pcie_advanced" "pcie"    "Fail" "Exit" 112)
  ,  (Simulation 8 "long_test" "default" "Fail" "Exit" 352)
  ,  (Simulation 9 "error_test" "default" "Error" "Exit" 352)
  ]

initCompiles : List Simulation
initCompiles =
  [  (Simulation 1 "simple_test" "default" "Pass" "Done" 1154)
  ,  (Simulation 2 "pcie_basic" "pcie"    "Pass" "Done" 912)
  ,  (Simulation 3 "wringout_test" "default" "Pass" "Done" 654)
  ]

initLints : List Simulation
initLints =
  [  (Simulation 1 "simple_test" "default" "Pass" "Done" 1154)
  ]
