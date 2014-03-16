{-# LANGUAGE TemplateHaskell, DeriveGeneric, DeriveDataTypeable #-}

module Hive.Messages
  (
-- debug messages
    IntMsg (..)
  , ChrMsg (..)
  , StrMsg (..)
  , TxtMsg (..)

-- messages from drones
  , DRegisterAtQ (..)
  , DWorkRequestS (..)
  , DWorkDoneS (..)

-- messages from clients
  , CSolveProblemQ (..)
  , CGetStatisticsQ (..)

-- messages from scheduler
  , SSolutionC (..)
  , SWorkReplyD (..)
  , SYourDronesW (..)
  , SSendSolutionW (..)

-- messages from warrior
  , WTaskS (..)
  , WGiveMeDronesS (..)

-- messages from queen
  , QRegisteredD (..)
  , QNewDroneS (..)
  , QDroneDisappearedS (..)
  , QWorkD (..)
  , QEnqueProblemS (..)
  , QStatisticsC (..)
  ) where

-------------------------------------------------------------------------------

import Data.Binary      (Binary, put, get)
import Data.Typeable    (Typeable)
import Data.Text        (Text)
import Data.Text.Binary ()
import Data.DeriveTH    (derive, makeBinary)
import GHC.Generics     (Generic)

import Hive.Types

-------------------------------------------------------------------------------

-- debug messages
data IntMsg             = IntMsg Int                             deriving (Generic, Typeable, Show)
data ChrMsg             = ChrMsg Char                            deriving (Generic, Typeable, Show)
data StrMsg             = StrMsg String                          deriving (Generic, Typeable, Show)
data TxtMsg             = TxtMsg Text                            deriving (Generic, Typeable, Show)

-- messages from drones
data DRegisterAtQ       = DRegisterAtQ Drone String              deriving (Generic, Typeable, Show)
data DWorkRequestS      = DWorkRequestS Drone                    deriving (Generic, Typeable, Show)
data DWorkDoneS         = DWorkDoneS Solution Client             deriving (Generic, Typeable, Show)

-- messages from clients
data CSolveProblemQ     = CSolveProblemQ ClientRequest           deriving (Generic, Typeable, Show)
data CGetStatisticsQ    = CGetStatisticsQ Client                 deriving (Generic, Typeable, Show)

-- messages from scheduler
data SSolutionC         = SSolutionC Solution                    deriving (Generic, Typeable, Show)
data SWorkReplyD        = SWorkReplyD Task                       deriving (Generic, Typeable, Show)
data SYourDronesW       = SYourDronesW [Drone]                   deriving (Generic, Typeable, Show)
data SSendSolutionW     = SSendSolutionW                         deriving (Generic, Typeable, Show)

-- messages from warrior
data WTaskS             = WTaskS Warrior Task                    deriving (Generic, Typeable, Show)
data WGiveMeDronesS     = WGiveMeDronesS Integer                 deriving (Generic, Typeable, Show)

-- messages from queen
data QRegisteredD       = QRegisteredD Scheduler Logger          deriving (Generic, Typeable, Show)
data QNewDroneS         = QNewDroneS Drone                       deriving (Generic, Typeable, Show)
data QDroneDisappearedS = QDroneDisappearedS Drone               deriving (Generic, Typeable, Show)
data QWorkD             = QWorkD Problem                         deriving (Generic, Typeable, Show)
data QEnqueProblemS     = QEnqueProblemS ClientRequest           deriving (Generic, Typeable, Show)
data QStatisticsC       = QStatisticsC Statistics                deriving (Generic, Typeable, Show)

-------------------------------------------------------------------------------

$(derive makeBinary ''IntMsg)
$(derive makeBinary ''ChrMsg)
$(derive makeBinary ''StrMsg)
$(derive makeBinary ''TxtMsg)

$(derive makeBinary ''DRegisterAtQ)
$(derive makeBinary ''DWorkRequestS)
$(derive makeBinary ''DWorkDoneS)

$(derive makeBinary ''CSolveProblemQ)
$(derive makeBinary ''CGetStatisticsQ)

$(derive makeBinary ''SSolutionC)
$(derive makeBinary ''SWorkReplyD)
$(derive makeBinary ''SYourDronesW)
$(derive makeBinary ''SSendSolutionW)

$(derive makeBinary ''WTaskS)
$(derive makeBinary ''WGiveMeDronesS)

$(derive makeBinary ''QRegisteredD)
$(derive makeBinary ''QNewDroneS)
$(derive makeBinary ''QDroneDisappearedS)
$(derive makeBinary ''QWorkD)
$(derive makeBinary ''QEnqueProblemS)
$(derive makeBinary ''QStatisticsC)