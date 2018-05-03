{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Explorer.DataTypes
  (
        GetCoin(..)
      , TrxPair
      , BlockTxs(..)
      , PagePair
      , Block(..)
  )
where

import Data.Aeson
import GHC.Generics


-- | general
data GetCoin = GetCoin {
    getCoin :: String
  }
  deriving (Show, Generic)
instance FromJSON GetCoin
instance ToJSON GetCoin

-- | transactions per block related
type TrxPair = (String, GetCoin)

data BlockTxs = BlockTxs {
    ctbId :: String,
    ctbTimeIssued :: Integer,
    ctbInputs :: [TrxPair],
    ctbOutputs :: [TrxPair],
    ctbInputSum :: GetCoin,
    ctbOutputSum :: GetCoin
  }
  deriving (Show, Generic)
instance FromJSON BlockTxs
instance ToJSON BlockTxs

-- | block related
type PagePair = (Integer, [Block])

data Block = Block {
    cbeEpoch :: Integer,
    cbeSlot :: Integer,
    cbeBlkHash :: String,
    cbeTimeIssued :: Integer,
    cbeTxNum :: Integer,
    cbeTotalSent:: GetCoin,
    cbeSize :: Integer,
    cbeBlockLead :: String,
    cbeFees :: GetCoin
  }
  deriving (Show, Generic)
instance FromJSON Block
instance ToJSON Block


