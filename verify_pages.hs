#!/usr/bin/env stack
-- stack --resolver lts-9.14 script --package postgresql-simple --package unix
{-# LANGUAGE OverloadedStrings #-}

import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow

import Control.Monad
import Control.Applicative

import System.Environment
import System.Exit

import qualified Config

-------------------------------------------------------------------------------
-- | query to be run
q :: Query
q = "SELECT COUNT(*) as n_blocks, pagenr \n\
   \ FROM block \n\
   \ WHERE pagenr > 0 \n\
   \ GROUP BY pagenr \n\
   \ HAVING COUNT(*) != 10;"

-------------------------------------------------------------------------------
-- | the result type of the above query
data Result = Result {
                       count :: Maybe Int
                     , pagenr :: Maybe Int
                     }

instance Show Result where
  show r = Config.asRed (show $ count r) ++ " in page " ++ Config.asBlue (show $ pagenr r)

instance FromRow Result where
  fromRow = Result <$> field <*> field


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

