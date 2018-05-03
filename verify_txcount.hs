#!/usr/bin/env stack
-- stack --resolver lts-9.14 script --package postgresql-simple --package time --package unix
{-# LANGUAGE OverloadedStrings #-}

import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow

import Control.Monad
import Control.Applicative

import Data.Time

import System.Environment
import System.Exit

import qualified Explorer.Config as Config

-------------------------------------------------------------------------------
-- | query to be run
q :: Query
q = "\
  \ SELECT t1.hash AS block_hash, t1.issued, t1.n_tx, t2.n_trxs AS tx_counted FROM \n\
  \   (SELECT blockid, n_tx, hash, issued FROM block) AS t1 \n\
  \   JOIN  \n\
  \   (SELECT blockid, COUNT(*) AS n_trxs \n\
  \    FROM transaction \n\
  \    GROUP BY transaction.blockid) AS t2 \n\
  \   ON \n\
  \   t1.blockid = t2.blockid \n\
  \   WHERE t1.n_tx != t2.n_trxs;"

-------------------------------------------------------------------------------
-- | the result type of the above query
data Result = Result {
                       hash :: Maybe String
                     , issued :: Maybe UTCTime
                     , n_tx :: Maybe Int
                     , tx_counted :: Maybe Int
                     }

instance Show Result where
  show r = Config.asRed ((show $ tx_counted r) ++ " != " ++ (show $ n_tx r)) ++ " in block " ++ Config.asBlue (show $ hash r) ++ " @ " ++ (show $ issued r)

instance FromRow Result where
  fromRow = Result <$> field <*> field <*> field <*> field


-------------------------------------------------------------------------------
-- | main entry point
main :: IO ()
main = do
  conn <- connect defaultConnectInfo {
      connectDatabase = Config.pgdatabase
    , connectUser = Config.pguser
    }

  r <- (query_ conn q) :: IO [Result]
  mapM_ print r

  case r of
    [] -> do
            putStrLn $ Config.asGreen "well done."
            exitSuccess
    _  -> do
            putStrLn $ Config.asRed "failure."
            exitWith (ExitFailure 1)

