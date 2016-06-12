module Initialize exposing (..)

import RegressionData exposing (..)

initialRegressions : List Regression
initialRegressions =
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
