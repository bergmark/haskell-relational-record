-- |
-- Module      : Data.PostgreSQL.NetworkAddress
-- Copyright   : 2015 Kei Hibino
-- License     : BSD3
--
-- Maintainer  : ex8k.hibino@gmail.com
-- Stability   : experimental
-- Portability : unknown
--
-- This module defines network-address types of PostgreSQL.
-- http://www.postgresql.org/docs/current/static/datatype-net-types.html
module Data.PostgreSQL.NetworkAddress
       ( NetAddress (..)
       , HostAddress, hostAddress, hostAddressOctets
       , V6HostAddress (..), v6HostAddressLong, v6HostAddressWords
       , v6HostAddress, v6HostAddressL, v6HostAddressR

       , Inet (..), Cidr (..)
       ) where

import Control.Applicative (pure)
import Control.Monad (guard)
import Data.Word (Word8, Word16, Word32)
import Data.Bits ((.&.), (.|.), shiftL, shiftR)


-- | Same as HostAddress of network package. Definition to reduce dependency.
type HostAddress = Word32

hostAddress :: Word8 -> Word8 -> Word8 -> Word8 -> HostAddress
hostAddress a b c d =
  fromIntegral a `shiftL` 24 .|.
  fromIntegral b `shiftL` 16 .|.
  fromIntegral c `shiftL`  8 .|.
  fromIntegral d

hostAddressOctets :: HostAddress -> (Word8, Word8, Word8, Word8)
hostAddressOctets ha =
    ( getWord8 24,
      getWord8 16,
      getWord8 8,
      getWord8 0 )
  where
    getWord8 n = fromIntegral $ (ha `shiftR` n) .&. 0xFF


-- | Not same as HostAddress6 of network package, because HostAddress6 has host-byteorder.
data V6HostAddress =
  V6HostAddress !Word16 !Word16 !Word16 !Word16 !Word16 !Word16 !Word16 !Word16
  deriving (Eq, Ord, Show)

v6HostAddressLong :: Word16 -> Word16 -> Word16 -> Word16
                  -> Word16 -> Word16 -> Word16 -> Word16
                  -> V6HostAddress
v6HostAddressLong = V6HostAddress

v6HostAddress :: [Word16] -> [Word16] -> Maybe V6HostAddress
v6HostAddress ls rs  = do
  let v6length = 8
  guard . null . drop v6length $ ls ++ rs
  [a, b, c, d, e, f, g, h]  <-  pure $ ls ++ replicate (v6length - length ls - length rs) 0 ++ rs
  pure $ v6HostAddressLong a b c d e f g h

v6HostAddressR :: [Word16] -> Maybe V6HostAddress
v6HostAddressR = v6HostAddress []

v6HostAddressL :: [Word16] -> Maybe V6HostAddress
v6HostAddressL ls = v6HostAddress ls []

v6HostAddressWords :: V6HostAddress -> (Word16, Word16, Word16, Word16, Word16, Word16, Word16, Word16)
v6HostAddressWords (V6HostAddress a b c d e f g h) =
  (a, b, c, d, e, f, g, h)


data NetAddress
  = NetAddress4 !HostAddress   !Word8
  | NetAddress6 !V6HostAddress !Word8
  deriving (Eq, Ord, Show)

newtype Inet = Inet NetAddress

newtype Cidr = Cidr NetAddress
