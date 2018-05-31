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
    [page0, page1] ->
      forM_ [((read page0)::Int)..((read page1)::Int)] $ \pageno -> do
            let q = "SELECT pagenr from page where pagenr=?"
            r <- (query conn q [pageno]) :: IO [Result]
            mapM_ print r

            if r == [] then do
                processPage conn (show pageno) True
                putStrLn $ "-- Page " ++ (show pageno) ++ Config.asGreen " successfully loaded!"
            else do
                processPage conn (show pageno) False
                putStrLn $ "-- Page " ++ (show pageno) ++ Config.asRed " already loaded!"
    _ -> do
        putStrLn $ Config.asRed "show_pages.hs <from> <to>"
        exitWith (ExitFailure 1)
