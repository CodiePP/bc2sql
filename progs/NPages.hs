{-# LANGUAGE OverloadedStrings #-}

import           System.Environment
import           System.Exit

import qualified Explorer.Config as Config
import           Explorer.ProcessPage (showPageHeight)


main :: IO ()
main = do
    showPageHeight
    exitSuccess
