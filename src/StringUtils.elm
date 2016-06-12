module StringUtils exposing (..)

import Set exposing (..)

uniquify : List String -> List String
uniquify list =
  Set.fromList list |> Set.toList
