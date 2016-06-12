module FormUtils exposing (onSelectChange, AllSelectData)

import Json.Decode as Json exposing (..)
import Html exposing (Attribute)
import Html.Events exposing (on)

type alias AllSelectData =
  {
    target : SelectValue
  }

type alias SelectValue =
  {
    name : String
  , value : String
  }

onSelectChange : (AllSelectData -> msg) -> Attribute msg
onSelectChange tagger =
  on "change" (Json.map tagger overallDecoder)


overallDecoder : Json.Decoder AllSelectData
overallDecoder =
  object1 AllSelectData
    ("target" := selectDecoder) 

selectDecoder : Json.Decoder SelectValue
selectDecoder =
  object2 SelectValue
    ("name" := string)
    ("value" := string)
