#!/usr/bin/env stack
-- stack --resolver lts-9.14 script --package wreq --package postgresql-simple --package aeson --package bytestring --package lens --package unix
--
{-# LANGUAGE OverloadedStrings #-}

import           System.Environment
import           System.Exit

import qualified Explorer.Config as Config
import           Explorer.ProcessPage (showPageHeight)


main :: IO ()
main = do
    showPageHeight
    exitSuccess
