{-# LANGUAGE LambdaCase          #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Explorer.ProcessBlock
  ( showBlock
  , processBlock
  )
where

import           Control.Lens  ((^.))
import           Control.Monad (forM_, void)

import           Data.Aeson    (decode)
import qualified Data.ByteString.Lazy as B
import           Data.String (fromString)

import           Database.PostgreSQL.Simple

import qualified Explorer.Config as Config
import           Explorer.DataTypes (BlockTxs(..), GetCoin(..), TrxPair)

import           Network.Wreq

decodeBlock :: B.ByteString -> Maybe (Either String [BlockTxs])
decodeBlock = decode

getBlock :: String -> IO (Maybe (Either String [BlockTxs]))
getBlock bhash = do
    resp' <- get $ Config.explorerUrl ++ "/api/blocks/txs/" ++ bhash
    return $ decodeBlock $ resp' ^. responseBody

processBlock :: Connection -> String -> Bool -> IO ()
processBlock conn bhash doSQL =
    getBlock bhash >>= \case
        Nothing ->
            putStrLn $ Config.asRed "failure!"
        Just (Left s) ->
            putStrLn $ Config.asRed "failure: " ++ s
        Just (Right txs) ->
           forM_ txs (\tx -> do
                let q0 = "SELECT trxid FROM transaction WHERE hash=?;"
                if not doSQL then
                   putStrLn q0
                else do
                    tx0::[Only Int] <- query conn (fromString q0) [ctbId tx]
                    case tx0 of
                       [] -> do
                           let q1 = "INSERT INTO transaction(blockid, hash, issued, suminput, sumoutput) VALUES((SELECT blockid FROM block WHERE hash=?), ?, to_timestamp(?), ?, ?) returning trxid"
                               a1 = (bhash, ctbId tx, show $ ctbTimeIssued tx, getCoin $ ctbInputSum tx, getCoin $ ctbOutputSum tx)
                           if not doSQL then
                               putStrLn q1
                           else do
                               trxs::[Only Int] <- query conn (fromString q1) a1
                               case trxs of
                                   [] -> putStrLn $ Config.asRed "cannot find transaction"
                                   [Only trxid] -> do
                                       forM_ (ctbInputs tx) (\addrval -> record_addr_val conn "input" trxid addrval doSQL)
                                       forM_ (ctbOutputs tx) (\addrval -> record_addr_val conn "output" trxid addrval doSQL)
                       _ -> putStrLn $ Config.asRed "transaction already exists"
                 )

record_addr_val :: Connection -> String -> Int -> TrxPair -> Bool -> IO ()
record_addr_val conn prefix trxid (addr, value) doSQL = do
    let q0 = "INSERT INTO address (hash) VALUES(?) ON CONFLICT DO NOTHING;"
    if not doSQL then
        putStrLn q0
    else
        void $ execute conn (fromString q0) [addr]
    let q1 = "INSERT INTO trxaddr" ++ prefix ++ "rel (trxid, addrid, value) VALUES(?, (SELECT addrid FROM address WHERE hash=?), ?);"
    if not doSQL then
        putStrLn q1
    else
        void $ execute conn (fromString q1) (trxid, addr, getCoin value)

showBlock :: String -> IO ()
showBlock bhash = do
    putStrLn $ "====================================="
    putStrLn $ "block:   " ++ bhash
    --resp' <- get $ Config.explorerUrl ++ "/api/blocks/txs/" ++ bhash
    --case decodeBlock $ resp' ^. responseBody of
    getBlock bhash >>= \case
        Nothing ->
           putStrLn "failure!"
        Just (Right txs) ->
           forM_ txs (\tx -> do
               putStrLn $ "-------------------------------------"
               putStrLn $ show tx
               )

