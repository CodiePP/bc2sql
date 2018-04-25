#!/usr/bin/env stack
-- stack --resolver lts-9.14 script --package wreq --package aeson --package lens --package unix
{-# LANGUAGE OverloadedStrings #-}

import Network.Wreq
import Data.Aeson
import Control.Lens  ((^.))
import System.Environment
import System.Exit

import qualified Config

main :: IO ()
main = do
  args <- getArgs
  case args of
    [bhash] -> do
                 resp <- get $ Config.explorerUrl ++ "/api/blocks/txs/" ++ bhash
                 putStrLn $ show $ resp ^. responseBody
                 exitWith ExitSuccess

    _ -> exitWith (ExitFailure 1)

