module TimeUtils exposing (..) 
import Date exposing (..)
import String exposing (length)

secondsInOneMinute : Int
secondsInOneMinute =
  60

secondsInOneHour : Int
secondsInOneHour =
  60 * secondsInOneMinute

zeroPad : Int -> String
zeroPad value =
  let
    valueString = toString value
  in
    case length valueString of
      0 -> "00"
      1 -> "0" ++ valueString
      _ -> valueString

stringToDate : String -> Date
stringToDate dateStr =
  case fromString dateStr of
    Ok a -> a
    -- Note that I never expect this to happen so I am returning the start
    -- of epoch. If this happens, we will get garbage results.
    Err a -> fromTime 0

dateDifferenceInSeconds : Date -> Date -> Float
dateDifferenceInSeconds startTime endTime =
  (toTime endTime - toTime startTime) / 1000

dateStrDifferenceInSeconds : String -> String -> Float
dateStrDifferenceInSeconds startTime endTime =
  dateDifferenceInSeconds (stringToDate startTime) (stringToDate endTime)

durationToString : Float -> String
durationToString duration =
  let
    durationInt = round duration
    hours = durationInt // secondsInOneHour
    grossMinutes = durationInt `rem` secondsInOneHour
    minutes = grossMinutes // secondsInOneMinute
    seconds = grossMinutes `rem` secondsInOneMinute
  in
    zeroPad hours ++ ":" ++ zeroPad minutes ++ ":" ++ zeroPad seconds
