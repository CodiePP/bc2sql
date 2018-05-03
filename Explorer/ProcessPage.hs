{-# LANGUAGE OverloadedStrings #-}

module Explorer.ProcessPage
  (
    decoder
  , showPage
  )
where

import Network.Wreq
import Data.Aeson    (decode)
import Control.Lens  ((^.))
import Control.Monad (forM_)

import qualified Data.ByteString.Lazy as B

import qualified Explorer.Config as Config
import Explorer.DataTypes (PagePair, Block(..), GetCoin(..))
import Explorer.ProcessBlock (showBlock)


decoder :: B.ByteString -> Maybe (Either String PagePair)
decoder = decode

showPage :: String -> IO ()
showPage pageno = do
    resp' <- get $ Config.explorerUrl ++ "/api/blocks/pages?page=" ++ pageno ++ "&pageSize=10"
    putStrLn $ "page:   " ++ pageno
    case decoder $ resp' ^. responseBody of
     Nothing ->
       putStrLn "failure!"
     Just (Right (n, bs)) -> do
       putStrLn $ "max pages:  " ++ (show n)
       forM_ bs (\b -> do
         putStrLn $ "======================================="
         putStrLn $ "epoch:  " ++ (show $ cbeEpoch b)
         putStrLn $ "slot:   " ++ (show $ cbeSlot b)
         putStrLn $ "issued: " ++ (show $ cbeTimeIssued b)
         putStrLn $ "block:  " ++ (show $ cbeBlkHash b)
         putStrLn $ "num tx: " ++ (show $ cbeTxNum b)
         putStrLn $ "size:   " ++ (show $ cbeSize b)
         putStrLn $ "sent:   " ++ (getCoin $ cbeTotalSent b)
         putStrLn $ "fees:   " ++ (getCoin $ cbeFees b)
         showBlock $ cbeBlkHash b
         )

