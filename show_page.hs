#!/usr/bin/env stack
-- stack --resolver lts-9.14 script --package wreq --package aeson --package bytestring --package lens --package unix
--
-- GHCi: stack ghci config.hs show_page.hs --package wreq --package aeson --package bytestring --package lens --package unix --extra-lib-dirs=/usr/local/opt/zlib/lib --extra-include-dirs=/usr/local/opt/zlib/include
--
{-# LANGUAGE OverloadedStrings #-}

import           System.Environment
import           System.Exit

import qualified Explorer.Config as Config
import           Explorer.ProcessPage (showPage)


main :: IO ()
main = do
  args <- getArgs
  case args of
    [pageno] -> do
        showPage pageno
        exitSuccess
    _ ->
        exitWith (ExitFailure 1)
