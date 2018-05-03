#!/usr/bin/env stack
-- stack --resolver lts-9.14 script --package wreq --package aeson --package lens --package unix
{-# LANGUAGE OverloadedStrings #-}

import Network.Wreq
import Data.Aeson
import Control.Lens  ((^.))
import System.Environment
import System.Exit

import qualified Explorer.Config as Config


callApi path params = do
  ext <- return $ case params of
    [] -> ""
    _ -> (++) "?" $ init $ foldr (\(p,v) acc -> acc ++ p ++ "=" ++ v ++ "&") "" params
  resp <- get $ Config.explorerUrl ++ path ++ ext
  putStrLn $ show $ resp ^. responseStatus --responseHeaders --responseBody

-- | last n transactions
--
tLastTrx =
  let path = "/api/txs/last"
  in
  callApi path []

-- | Ada supply
--
tAdaSupply =
  let path = "/api/supply/ada"
  in
  callApi path []

main :: IO ()
main = do
  --
  tLastTrx
  --
  tAdaSupply
  --
  exitSuccess
