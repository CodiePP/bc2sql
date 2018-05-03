#!/usr/bin/env stack
-- stack --resolver lts-9.14 script --package wreq --package aeson --package bytestring --package lens --package unix
--
-- GHCi: stack ghci config.hs show_page.hs --package wreq --package aeson --package bytestring --package lens --package unix --extra-lib-dirs=/usr/local/opt/zlib/lib --extra-include-dirs=/usr/local/opt/zlib/include
--
{-# LANGUAGE OverloadedStrings #-}

import System.Environment
import System.Exit

import qualified Explorer.Config as Config
import Explorer.ProcessPage (decoder, showPage)


testData = "{\"Right\":[95446,[{\"cbeEpoch\":1,\"cbeSlot\":11748,\"cbeBlkHash\":\"dc220b4e4384f5b8d21f78a7ae666e59dcb7fd4d6794a1411d3e016d0d9233d3\",\"cbeTimeIssued\":1506870051,\"cbeTxNum\":1,\"cbeTotalSent\":{\"getCoin\":\"1923474000000\"},\"cbeSize\":909,\"cbeBlockLead\":\"1deb82908402c7ee3efeb16f369d97fba316ee621d09b32b8969e54b\",\"cbeFees\":{\"getCoin\":\"0\"}},{\"cbeEpoch\":1,\"cbeSlot\":11747,\"cbeBlkHash\":\"119e04575a7a2281c4bc7ab319524ef09b9e3c2d2f4d4cdd3b7fbeafffce369c\",\"cbeTimeIssued\":1506870031,\"cbeTxNum\":0,\"cbeTotalSent\":{\"getCoin\":\"0\"},\"cbeSize\":666,\"cbeBlockLead\":\"43011479a595b300e0726910d0b602ffcdd20466a3b8ceeacd3fbc26\",\"cbeFees\":{\"getCoin\":\"0\"}},{\"cbeEpoch\":1,\"cbeSlot\":11746,\"cbeBlkHash\":\"ddbb6afbd7c26e7148fb0fac7e15a02fd1d85c73145a03108d3647d04b97a835\",\"cbeTimeIssued\":1506870011,\"cbeTxNum\":1,\"cbeTotalSent\":{\"getCoin\":\"1692307000000\"},\"cbeSize\":909,\"cbeBlockLead\":\"6c9e14978b9d6629b8703f4f25e9df6ed4814b930b8403b0d45350ea\",\"cbeFees\":{\"getCoin\":\"0\"}},{\"cbeEpoch\":1,\"cbeSlot\":11745,\"cbeBlkHash\":\"180548900b02e3cedb78b550abb4a130b1af5440b5cdb8a7aab507a430831f4e\",\"cbeTimeIssued\":1506869991,\"cbeTxNum\":1,\"cbeTotalSent\":{\"getCoin\":\"649822000000\"},\"cbeSize\":909,\"cbeBlockLead\":\"af2800c124e599d6dec188a75f8bfde397ebb778163a18240371f2d1\",\"cbeFees\":{\"getCoin\":\"0\"}},{\"cbeEpoch\":1,\"cbeSlot\":11744,\"cbeBlkHash\":\"55e1c98361afac115719eb8cbf3d55ff4823ce3d41c748e840b7aae8b3fccedc\",\"cbeTimeIssued\":1506869971,\"cbeTxNum\":1,\"cbeTotalSent\":{\"getCoin\":\"705402000000\"},\"cbeSize\":909,\"cbeBlockLead\":\"1deb82908402c7ee3efeb16f369d97fba316ee621d09b32b8969e54b\",\"cbeFees\":{\"getCoin\":\"0\"}},{\"cbeEpoch\":1,\"cbeSlot\":11743,\"cbeBlkHash\":\"e7c29afd61db8e71c82b8f706321cf5fff762bac3b90aaffc0b41787922a7545\",\"cbeTimeIssued\":1506869951,\"cbeTxNum\":2,\"cbeTotalSent\":{\"getCoin\":\"3174733000000\"},\"cbeSize\":1152,\"cbeBlockLead\":\"6c9e14978b9d6629b8703f4f25e9df6ed4814b930b8403b0d45350ea\",\"cbeFees\":{\"getCoin\":\"0\"}},{\"cbeEpoch\":1,\"cbeSlot\":11742,\"cbeBlkHash\":\"225c09282df5953e5d68f4df7fab50bbb5c854b6c34c684b3b38f3ee5e64cbf0\",\"cbeTimeIssued\":1506869931,\"cbeTxNum\":0,\"cbeTotalSent\":{\"getCoin\":\"0\"},\"cbeSize\":666,\"cbeBlockLead\":\"5071d8802ddd05c59f4db907bd1749e82e6242caf6512b20a8368fcf\",\"cbeFees\":{\"getCoin\":\"0\"}},{\"cbeEpoch\":1,\"cbeSlot\":11741,\"cbeBlkHash\":\"30641bb99f50950f468dc9656c9854fc990de5dbff49c48b8c4e35beb224eb6d\",\"cbeTimeIssued\":1506869911,\"cbeTxNum\":0,\"cbeTotalSent\":{\"getCoin\":\"0\"},\"cbeSize\":666,\"cbeBlockLead\":\"65904a89e6d0e5f881513d1736945e051b76f095eca138ee869d543d\",\"cbeFees\":{\"getCoin\":\"0\"}},{\"cbeEpoch\":1,\"cbeSlot\":11740,\"cbeBlkHash\":\"0d1404fb6e23611c9ea89d57b4c8431ac3b1d8a377c95e4c13a4d74969db1050\",\"cbeTimeIssued\":1506869891,\"cbeTxNum\":1,\"cbeTotalSent\":{\"getCoin\":\"763781000000\"},\"cbeSize\":909,\"cbeBlockLead\":\"5071d8802ddd05c59f4db907bd1749e82e6242caf6512b20a8368fcf\",\"cbeFees\":{\"getCoin\":\"0\"}},{\"cbeEpoch\":1,\"cbeSlot\":11739,\"cbeBlkHash\":\"2c635fc4a26e1eb4307de205ec3bd1836e2f37c67185e9e8e7663fd57721b264\",\"cbeTimeIssued\":1506869871,\"cbeTxNum\":1,\"cbeTotalSent\":{\"getCoin\":\"576923000000\"},\"cbeSize\":909,\"cbeBlockLead\":\"5411c7bf87c252609831a337a713e4859668cba7bba70a9c3ef7c398\",\"cbeFees\":{\"getCoin\":\"0\"}}]]}"

testData' = "{\"Right\":[95446,[{\"cbeEpoch\":1,\"cbeSlot\":11748,\"cbeBlkHash\":\"dc220b4e4384f5b8d21f78a7ae666e59dcb7fd4d6794a1411d3e016d0d9233d3\",\"cbeTimeIssued\":1506870051,\"cbeTxNum\":1,\"cbeTotalSent\":{\"getCoin\":\"1923474000000\"},\"cbeSize\":909,\"cbeBlockLead\":\"1deb82908402c7ee3efeb16f369d97fba316ee621d09b32b8969e54b\",\"cbeFees\":{\"getCoin\":\"0\"}}]]}"


test1 = decoder testData


main :: IO ()
main = do
  args <- getArgs
  case args of
    [pageno] -> do
        showPage pageno
        exitSuccess
    _ ->
        exitWith (ExitFailure 1)
