module FormUtils exposing (onSelectChange)

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
