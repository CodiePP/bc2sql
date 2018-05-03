#!/usr/bin/env stack
-- stack --resolver lts-9.14 script --package wreq --package aeson --package bytestring --package lens --package unix
--
-- GHCi: stack ghci config.hs show_block.hs --package wreq --package aeson --package bytestring --package lens --package unix --extra-lib-dirs=/usr/local/opt/zlib/lib --extra-include-dirs=/usr/local/opt/zlib/include
--
{-# LANGUAGE OverloadedStrings #-}

import System.Environment
import System.Exit

import Explorer.ProcessBlock (decoder, showBlock)

-- block: 27b0471fa372485ae569a3657f6c9a0b8d6c36874f3aaa6a2c4e7147befbe2c0
testData = "{\"Right\":[{\"ctbId\":\"71d2dfe85a1eafe76a0c67b38ec6ae8de13d2bbf74084f1a12de3176af40011c\",\"ctbTimeIssued\":1524832551,\"ctbInputs\":[[\"DdzFFzCqrht21mjxeva9rTX9mbZDkoNEcQkRaKCwd4u4FwU1aZ57bpEnHoSo1QWtyqYKETfqvWjeBWGL3wcVKpYZ5kfBdFhWtnExxsEP\",{\"getCoin\":\"4746735782\"}]],\"ctbOutputs\":[[\"DdzFFzCqrhsyGyJB2mK6VT3mhUrHMrrDhQf4LqNDHuai7en2XwDfvULaSGcUPVKm6sJHVTikbQNJDtbVubnRhnbKkWecmfh3zZX8pzkx\",{\"getCoin\":\"4745564712\"}],[\"DdzFFzCqrhsfkegDcdUJAGBRoUP2LVakkby6ntdckcURzBsKmNJ7HmQ6LBwLZxTRVBvhZzuFuX9KUpraDcqhJavm35yeXgS2keJPHfKB\",{\"getCoin\":\"1000000\"}]],\"ctbInputSum\":{\"getCoin\":\"4746735782\"},\"ctbOutputSum\":{\"getCoin\":\"4746564712\"}}]}"


test1 = decoder testData

main :: IO ()
main = do
    args <- getArgs
    case args of
        [bhash] -> do
                      showBlock bhash
                      exitSuccess
        _ ->
                      exitWith (ExitFailure 1)

