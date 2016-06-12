module HtmlUtils exposing (..)

import Html exposing (..)

listToHtmlSelectOptions : List String -> List (Html a)
listToHtmlSelectOptions list =
  list
  |> List.map toSelectOption

toSelectOption : String -> Html a
toSelectOption elem =
  option [] [text elem]
