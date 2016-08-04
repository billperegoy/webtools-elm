module Config exposing (..)

import Dict exposing (..)
import ResultsTableData exposing (..)

apiBase : String
apiBase = "http://localhost:9292/api/"

initCompileColumns : List Column
initCompileColumns =
  [
    --     name     visible sortable filterable order     filters
    ----------------------------------------------------------------
    Column "Name"   True    True     False      Ascending Dict.empty
  , Column "Config" True    True     True       Unsorted  Dict.empty
  , Column "Status" True    True     True       Unsorted  Dict.empty
  ] ++ initLsfColumns

initLintColumns : List Column
initLintColumns =
  [
    Column "Name" True True False Ascending Dict.empty
  , Column "Status" True True True Unsorted Dict.empty
  ] ++ initLsfColumns

initSimColumns : List Column
initSimColumns =
  [
    Column "#" True True False Ascending Dict.empty
  , Column "Name" True True False Unsorted Dict.empty
  , Column "Config" True True True Unsorted Dict.empty
  , Column "Status" True True True Unsorted Dict.empty
  ] ++ initLsfColumns

--
-- common LSF columns used by all types
--
initLsfColumns : List Column
initLsfColumns = 
  [
    --     name         visible sortable filterable order    filters
    ----------------------------------------------------------------
    Column "Lsf Status" True    True     True       Unsorted Dict.empty
  , Column "Run Time"   True    True     False      Unsorted Dict.empty
  , Column "Host"       False   True     True       Unsorted Dict.empty
  , Column "LSF ID"     False   True     True       Unsorted Dict.empty
  ]
