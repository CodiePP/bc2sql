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
  deriving (Generic)
instance FromJSON BlockTxs
instance ToJSON BlockTxs

instance Show BlockTxs where
  show tx = "id:     " ++ ctbId tx ++ "\n" ++
            "issued: " ++ (show $ ctbTimeIssued tx) ++ "\n" ++
            (inputs (ctbInputs tx))  ++
            (outputs (ctbOutputs tx)) ++
            "sum <-: " ++ (getCoin $ ctbInputSum tx) ++ "\n" ++
            "sum ->: " ++ (getCoin $ ctbOutputSum tx) ++ "\n" ++
            "fees  : " ++ (show $ (-) (read (getCoin $ ctbInputSum tx) :: Integer) (read (getCoin $ ctbOutputSum tx) :: Integer))
              where
                inputs  = foldr (\t a -> a ++ "input:  " ++ (getCoin $ snd t) ++ " @ " ++ (fst t) ++ "\n") ""
                outputs = foldr (\t a -> a ++ "output:  " ++ (getCoin $ snd t) ++ " @ " ++ (fst t) ++ "\n") ""

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
  deriving (Generic)
instance FromJSON Block
instance ToJSON Block

instance Show Block where
  show b = "epoch:  " ++ (show $ cbeEpoch b) ++ "\n" ++
           "slot:   " ++ (show $ cbeSlot b) ++ "\n" ++
           "issued: " ++ (show $ cbeTimeIssued b) ++ "\n" ++
           "block:  " ++ (show $ cbeBlkHash b) ++ "\n" ++
           "num tx: " ++ (show $ cbeTxNum b) ++ "\n" ++
           "size:   " ++ (show $ cbeSize b) ++ "\n" ++
           "sent:   " ++ (getCoin $ cbeTotalSent b) ++ "\n" ++
           "fees:   " ++ (getCoin $ cbeFees b)
