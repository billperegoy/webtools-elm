module RegressionSelectData exposing (..)

import Json.Decode as Json exposing (..)

type alias Regression =
  {
    name : String
  , project : String
  , runType : String 
  , user : String
  }

decodeRegression : Json.Decoder Regression
decodeRegression =
  Json.object4 Regression
    ("name" := Json.string)
    ("proj" := Json.string)
    ("run_type" := Json.string)
    ("user" := Json.string)


decodeRegressionList : Json.Decoder (List Regression)
decodeRegressionList =
  Json.list decodeRegression 
