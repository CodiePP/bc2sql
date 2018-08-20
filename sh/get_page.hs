#!/usr/bin/env stack
-- stack --resolver lts-9.14 script --package wreq --package aeson --package postgresql-simple --package bytestring --package lens --package unix
--
--
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase        #-}

import           System.Environment
import           System.Exit

import           Control.Monad
import           Control.Applicative

import           Database.PostgreSQL.Simple
import           Database.PostgreSQL.Simple.FromRow

import qualified Explorer.Config as Config
import           Explorer.ProcessPage (processPage)


q :: Query
q = "SELECT pagenr from page where pagenr=?"

data Result = Result {
    pagenr :: Maybe Int
  } deriving (Eq, Show)

instance FromRow Result where
  fromRow = Result <$> field


main :: IO ()
main = do
  conn <- connect defaultConnectInfo {
      connectDatabase = Config.pgdatabase
    , connectUser = Config.pguser
    }

  args <- getArgs
  case args of
    [pageno] -> do

        r <- (query conn q [pageno]) :: IO [Result]
        mapM_ print r

        if r == [] then do
            processPage conn pageno True
            putStrLn $ "-- Page " ++ pageno ++ Config.asGreen " successfully loaded!"
            exitSuccess
        else do
            processPage conn pageno False
            putStrLn $ "-- Page " ++ pageno ++ Config.asRed " already loaded!"
            exitWith (ExitFailure 1)
    _ ->
        exitWith (ExitFailure 1)
