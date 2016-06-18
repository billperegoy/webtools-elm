module FormUtils exposing (onSelectChange, onCheckBoxChange, CheckBoxData)

import Json.Decode as Json exposing (..)
import Html exposing (Attribute)
import Html.Events exposing (on)

{-
  The select element returns Json that looks like this:

  "target" : {
    "value" : "the_string_value"
  }

  This uses a simple Json decoder that burrows into that
  Json structure and pulls out just the string representing
  the value.
-}

onSelectChange : (String -> msg) -> Attribute msg
onSelectChange tagger =
  on "change" (Json.map tagger targetValue)

targetValue : Json.Decoder String
targetValue =
  at ["target", "value"] string


type alias CheckBoxData =
  {
    target : CheckBoxValue
  }

type alias CheckBoxValue =
  {
    name : String
  , checked : Bool
  }

overallDecoder : Json.Decoder CheckBoxData
overallDecoder =
  object1 CheckBoxData
    ("target" := checkBoxDecoder)

checkBoxDecoder : Json.Decoder CheckBoxValue
checkBoxDecoder =
  object2 CheckBoxValue
    ("name" := string)
    ("checked" := bool)

onCheckBoxChange : (CheckBoxData -> msg) -> Attribute msg
onCheckBoxChange tagger =
  on "change" (Json.map tagger overallDecoder)

