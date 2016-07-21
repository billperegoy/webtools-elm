module Initialize exposing (..)

import Dict exposing (..)

import Api exposing (..)
import SummaryData exposing (..)
import ResultsTableData exposing (..)

initLsfInfo : LsfViewData
initLsfInfo =
  LsfViewData "1234" "Pass" "nrlnx23" 12345

initSummary : Summary
initSummary = 
  {
    regressionToolVersion = ""
  , runName = ""
  , project = ""
  , user = ""
  , site = ""
  , runType = ""
  , gvpLabel = Nothing
  , startDate = "" 
  , endDate = "" 
  , startDay = ""
  , lsfJobSuffix = ""
  , active  = True
  , timedOut = False
  , gvpMergeError = False
  , elapsedTime = Nothing
  , success = 0
  }
