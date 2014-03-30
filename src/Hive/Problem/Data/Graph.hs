{-# LANGUAGE TemplateHaskell, DeriveGeneric, DeriveDataTypeable #-}
{-# OPTIONS_GHC -fno-warn-type-defaults #-}

module Hive.Problem.Data.Graph
  ( Graph
  , Path
  , Node
  , mkDirectedGraph
  , (<+>)
  , size
  , nodes
  , distance
  , addEdge
  , updateEdge
  , neighbours
  , pathLength
  , shorterPath
  , partition
  , partitions
  , parse
  ) where

import Data.Text.Lazy.Internal (Text)
import Data.Text.Lazy.Encoding (encodeUtf8)

import Data.Binary         (Binary, get, put, putWord8, getWord8)
import Data.DeriveTH       (derive, makeBinary)
import Data.Typeable       (Typeable)
import GHC.Generics        (Generic)

import Data.Aeson          (decode')
import Data.Aeson.TH       (deriveJSON, defaultOptions)

import Data.List           ((\\), unfoldr)
import Data.IntMap.Strict  (IntMap)
import Control.Applicative (Applicative, (<$>), (<*>))
import Control.Arrow       ((&&&), first, second)

-------------------------------------------------------------------------------

import qualified Data.IntMap.Strict as Map (empty, singleton, keys, filterWithKey, lookup, insertWith, union, size, partitionWithKey)

-------------------------------------------------------------------------------

type Size     = Int
type Node     = Int
type Distance = Int
type Path     = [Node]
type Position = (Int, Int)
type Matrix   = IntMap (IntMap Distance)

data Graph = DirectedGraph !Matrix
           | PositionList  (IntMap Position)
  deriving (Eq, Show, Generic, Typeable)

-------------------------------------------------------------------------------

$(derive makeBinary ''Graph)

$(deriveJSON defaultOptions ''Graph)

-------------------------------------------------------------------------------

(<+>) :: (Applicative a, Num n) => a n -> a n -> a n
m <+> n = (+) <$> m <*> n

mkDirectedGraph :: Graph
mkDirectedGraph = DirectedGraph Map.empty

size :: Graph -> Size
size (DirectedGraph m ) = Map.size m
size (PositionList  ps) = fromIntegral . Map.size $ ps

nodes :: Graph -> [Node]
nodes (DirectedGraph m ) = Map.keys m
nodes (PositionList  ps) = Map.keys ps

distance :: Graph -> Node -> Node -> Maybe Distance
distance (DirectedGraph m ) from to = from `Map.lookup` m >>= \m' -> to `Map.lookup` m'
distance (PositionList  ps) from to =
  from `Map.lookup` ps >>= \(x1,y1) ->
  to   `Map.lookup` ps >>= \(x2,y2) ->
  Just . round . sqrt . fromIntegral $ ((x1-x2)^2 + (y1-y2)^2)

addEdge :: Graph -> Node -> Node -> Distance -> Graph
addEdge (DirectedGraph m) from to d = DirectedGraph $ Map.insertWith Map.union from (Map.singleton to d) m -- ToDo: something more intelligent than union (?)
addEdge (PositionList  _) _    _  _ = error "This graph is complete, you cannot add an edge."

updateEdge :: Graph -> Node -> Node -> Distance -> Graph
updateEdge g@(DirectedGraph _) = addEdge g
updateEdge g@(PositionList  _) = addEdge g

neighbours :: Graph -> Node -> [Node]
neighbours (DirectedGraph m) from =
  case from `Map.lookup` m of
    Just m' -> Map.keys m'
    Nothing -> []
neighbours g@(PositionList  _  ) from = nodes g \\ [from]

pathLength :: Graph -> Path -> Maybe Distance
pathLength g p = foldr ((<+>) . uncurry (distance g)) (Just 0) $ p `zip` tail p

shorterPath :: Graph -> Path -> Path -> Path
shorterPath g p1 p2 = shorterPath' (p1, f p1) (p2, f p2)
  where
    f :: Path -> Maybe Distance
    f = pathLength g

    shorterPath' :: (Path, Maybe Distance) -> (Path, Maybe Distance) -> Path
    shorterPath' (p1', Nothing) (_,   Nothing) = p1'
    shorterPath' (p1', Just _ ) (_,   Nothing) = p1'
    shorterPath' (_,   Nothing) (p2', Just _ ) = p2'
    shorterPath' (p1', Just l1) (p2', Just l2) | l1 <= l2   = p1'
                                               | otherwise  = p2'

partition :: Graph -> Node -> Node -> Graph
partition (DirectedGraph m) n0 n1 =
  let m' = Map.filterWithKey (\k _ -> k <= n1 && k > n0) m
  in  DirectedGraph m'
partition (PositionList ps) n0 n1 = PositionList $ Map.filterWithKey (\k _ -> k > n0 && k <= n1) ps

partitions :: Graph -> Int -> Int -> [Graph]
partitions (DirectedGraph m) parts indicator =
  let unF (m', i) = if i < parts then Just
                                    . first DirectedGraph
                                    . second (id &&& const (i+1))
                                    . Map.partitionWithKey (\k _ -> k <= (i+1)*indicator)
                                    $ m'
                                 else Nothing
  in  unfoldr unF (m, 0)
partitions (PositionList _) _ _ = undefined

-------------------------------------------------------------------------------

parse :: Text -> Maybe Graph
parse = decode' . encodeUtf8