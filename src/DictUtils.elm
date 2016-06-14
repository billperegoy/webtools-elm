module DictUtils exposing (..)

import Dict exposing (..)

getWithDefault : Dict String a -> String -> a -> a
getWithDefault items key default =
  case Dict.get key items of
    Just a -> a
    Nothing -> default
