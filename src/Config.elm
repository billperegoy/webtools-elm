module Config exposing (..)

import Dict exposing (..)
import TimeUtils exposing (..)
import ResultsTableData exposing (..)

apiBase : String
apiBase = "http://localhost:9292/api/"

initCompileColumns : List Column
initCompileColumns =
  [
    --     name     visible sortable filterable order     filters    width link?
    ----------------------------------------------------------------------------
    Column "Name"   True    True     False      Ascending Dict.empty   100
           (\col -> col.name)
           (List.sortBy (\col -> col.name))
  , Column "Config" True    True     True       Unsorted  Dict.empty 100
           (\col -> col.config)
           (List.sortBy (\col -> col.config))
  , Column "Status" True    True     True       Unsorted  Dict.empty 100
           (\col -> col.status)
           (List.sortBy (\col -> col.status))
  ] ++ initLsfColumns

initLintColumns : List Column
initLintColumns =
  [
    Column "Name" True True False Ascending Dict.empty 100
           (\col -> col.name)
           (List.sortBy (\col -> col.name))
  , Column "Status" True True True Unsorted Dict.empty 100
           (\col -> col.status)
           (List.sortBy (\col -> col.status))
  ] ++ initLsfColumns

initSimColumns : List Column
initSimColumns =
  [
    Column "#" True True False Ascending Dict.empty 10
           (\col -> col.runNum |> toString)
           (List.sortBy (\col -> col.runNum))
  , Column "Name" True True False Unsorted Dict.empty 700
           (\col -> col.name)
           (List.sortBy (\col -> col.name))
  , Column "Config" True True True Unsorted Dict.empty 100
           (\col -> col.config)
           (List.sortBy (\col -> col.config))
  , Column "Status" True True True Unsorted Dict.empty 100
           (\col -> col.status)
           (List.sortBy (\col -> col.status))
  , Column "LSF Log" True True True Unsorted Dict.empty 100
           --(\col -> "<a href=\"" ++ col.lsfLogFile ++ ">log<\a>")
           (\col -> "log")
           (List.sortBy (\col -> col.lsfLogFile))
  ] ++ initLsfColumns

--
-- common LSF columns used by all types
--
initLsfColumns : List Column
initLsfColumns = 
  [
    --     name         visible sortable filterable order    filters
    ----------------------------------------------------------------
    Column "Lsf Status" True    True     True       Unsorted Dict.empty 100
           (\col -> col.lsfInfo.status)
           (List.sortBy (\col -> col.lsfInfo.status))
  , Column "Run Time"   True    True     False      Unsorted Dict.empty 100
           (\col -> col.lsfInfo.elapsedTime |> Basics.toFloat |> durationToString)
           (List.sortBy (\col -> col.lsfInfo.elapsedTime))
  , Column "Host"       False   True     True       Unsorted Dict.empty 100
           (\col -> col.lsfInfo.execHost)
           (List.sortBy (\col -> col.lsfInfo.execHost))
  , Column "LSF ID"     False   True     True       Unsorted Dict.empty 100
           (\col -> col.lsfInfo.jobId)
           (List.sortBy (\col -> col.lsfInfo.jobId))
  ]
