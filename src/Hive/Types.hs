{-# LANGUAGE TemplateHaskell, DeriveGeneric, DeriveDataTypeable #-}

module Hive.Types
  ( Timeout (unTimeout)
  , milliseconds, seconds, minutes, hours
  , Host
  , Port
  , Master (..)
  , Problem (..)
  , ProblemType (..)  -- reexporting
  , Instance (..)
  , Solution (..)
  ) where

-------------------------------------------------------------------------------

import Hive.Imports.MkBinary
import Hive.Problem.Types

import Control.Distributed.Process (ProcessId)

-------------------------------------------------------------------------------

newtype Timeout = Timeout { unTimeout :: Int }  deriving (Eq, Show)

type Host = String
type Port = String

newtype Master = Master ProcessId deriving (Eq, Generic, Typeable)
instance Show Master where
  show (Master pid) = show pid
instance Binary Master where

-------------------------------------------------------------------------------

milliseconds :: Int -> Timeout
milliseconds ms = Timeout (1000 * ms)

seconds :: Int -> Timeout
seconds s = milliseconds (1000 * s)

minutes :: Int -> Timeout
minutes m = seconds (60 * m)

hours :: Int -> Timeout
hours h = minutes (60 * h)