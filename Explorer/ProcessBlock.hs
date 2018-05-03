{-# LANGUAGE OverloadedStrings #-}

module Explorer.ProcessBlock
  (
    decoder
  , showBlock
  )
where

import Network.Wreq
import Data.Aeson    (decode)
import Control.Lens  ((^.))
import Control.Monad (forM_)

import qualified Data.ByteString.Lazy as B

import qualified Explorer.Config as Config
import Explorer.DataTypes (BlockTxs(..), GetCoin(..))


decoder :: B.ByteString -> Maybe (Either String [BlockTxs])
decoder = decode

showBlock :: String -> IO ()
showBlock bhash = do
    resp' <- get $ Config.explorerUrl ++ "/api/blocks/txs/" ++ bhash
    putStrLn $ "====================================="
    putStrLn $ "block:   " ++ bhash
    case decoder $ resp' ^. responseBody of
      Nothing -> do
         putStrLn "failure!"
      Just (Right txs) -> do
         forM_ txs (\tx -> do
             putStrLn $ "-------------------------------------"
             putStrLn $ "id:     " ++ ctbId tx
             putStrLn $ "issued: " ++ (show $ ctbTimeIssued tx)
             forM_ (ctbInputs tx) (\t -> putStrLn $ "input:  " ++ (getCoin $ snd t) ++ " @ " ++ (fst t))
             forM_ (ctbOutputs tx) (\t -> putStrLn $ "output: " ++ (getCoin $ snd t) ++ " @ " ++ (fst t))
             putStrLn $ "sum <-: " ++ (getCoin $ ctbInputSum tx)
             putStrLn $ "sum ->: " ++ (getCoin $ ctbOutputSum tx)
             putStrLn $ "fees  : " ++ (show $ (-) (read (getCoin $ ctbInputSum tx) :: Integer) (read (getCoin $ ctbOutputSum tx) :: Integer))
             )


