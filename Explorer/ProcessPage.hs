{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE OverloadedStrings #-}

module Explorer.ProcessPage
  ( showPage
  , processPage
  , showPageHeight
  )
where

import           Network.Wreq
import           Control.Lens  ((^.))
import           Control.Monad (forM_, void)

import           Data.Aeson (decode)
import qualified Data.ByteString.Lazy as B
import           Data.String (fromString)
import           Database.PostgreSQL.Simple

import qualified Explorer.Config as Config
import           Explorer.DataTypes (PagePair, Block(..), GetCoin(..))
import           Explorer.ProcessBlock (showBlock, processBlock)

decodePage :: B.ByteString -> Maybe (Either String PagePair)
decodePage = decode

getPage :: String -> IO (Maybe (Either String PagePair))
getPage pageno = do
    resp' <- get $ Config.explorerUrl ++ "/api/blocks/pages?page=" ++ pageno ++ "&pageSize=10"
    return $ decodePage $ resp' ^. responseBody

processPage :: Connection -> String -> Bool -> IO ()
processPage conn pageno doSQL = do
    getPage pageno >>= \case
       Nothing ->
         putStrLn "failure!"
       Just (Left s) ->
         putStrLn $ "failure: " ++ s
       Just (Right (_, bs)) -> withTransaction conn $ do
         let q0 = "INSERT INTO page VALUES(?) ON CONFLICT DO NOTHING;"
         if not doSQL then
             putStrLn q0
         else
             void $ execute conn (fromString q0) [pageno]
         forM_ bs (\b -> do
           let q1 = "INSERT INTO leader (hash) VALUES(?) ON CONFLICT DO NOTHING;"
           if not doSQL then
               putStrLn q1
           else
               void $ execute conn (fromString q1) [cbeBlockLead b]
           let q2 = "INSERT INTO block (pagenr, epoch, slot, hash, issued, n_tx, sent, size, leader, fees) VALUES(?,?,?,?,to_timestamp(?),?,?,?,(SELECT leaderid FROM leader WHERE hash=?),?)"
               a2 = (pageno, cbeEpoch b, cbeSlot b, cbeBlkHash b, show $ cbeTimeIssued b, cbeTxNum b, getCoin $ cbeTotalSent b, cbeSize b, cbeBlockLead b, getCoin $ cbeFees b)
           if not doSQL then
               putStrLn q2
           else do
               void $ execute conn (fromString q2) a2
               processBlock conn (cbeBlkHash b) doSQL
           )
         return ()

showPage :: String -> IO ()
showPage pageno = do
    getPage pageno >>= \case
       Nothing ->
         putStrLn "failure!"
       Just (Right (n, bs)) -> do
         putStrLn $ "max pages:  " ++ (show n)
         forM_ bs (\b -> do
           putStrLn $ "================================BLOCK=="
           putStrLn $ show b
           showBlock $ cbeBlkHash b
           )
         return ()

showPageHeight :: IO (Int)
showPageHeight = do
    resp' <- get $ Config.explorerUrl ++ "/api/blocks/pages/total"
    case decoder $ resp' ^. responseBody of
           Nothing -> do
             putStrLn "failure!"
             return 0
           Just (Left s) -> do
             putStrLn $ "failure: " ++ s
             return 0
           Just (Right n) -> do
             putStrLn $ "max pages:  " ++ (show n)
             return n
    where
        decoder :: B.ByteString -> Maybe (Either String Int)
        decoder = decode
