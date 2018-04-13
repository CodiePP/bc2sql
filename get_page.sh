#!/usr/bin/env bash

if [ $# -ne 1 ]; then
  echo "$0 <page#>"
  exit 1
fi

PAGENR=$1

PAYLOAD=`curl -s https://cardanoexplorer.com/api/blocks/pages?page=${PAGENR}\&pageSize=10`

PAGEMAX=`echo "${PAYLOAD}" | jq '.Right|.[0]'`

if [ -z "$PAGEMAX" ]; then
  echo "No match."
  exit 1
fi

BLIST=`echo "${PAYLOAD}" | jq '.Right|.[1]'`

for N in `seq 0 9`; do
   echo "${BLIST}" | jq -r '.['${N}'] | ["leader"] as $keys | [.cbeBlockLead] as $values | $keys, $values | @csv' | {
     OLDIFS=${IFS}
     IFS=','
     read H1
     read BLKLEAD
     BLKLEAD=$(echo $BLKLEAD | tr '"' "'")
     echo "INSERT INTO leader (hash) VALUES(${BLKLEAD}) ON CONFLICT DO NOTHING;"
     IFS=${OLDIFS}
   }
done

echo "BEGIN TRANSACTION;"
echo "INSERT INTO page VALUES(${PAGENR}) ON CONFLICT DO NOTHING;"

for N in `seq 0 9`; do
   echo "${BLIST}" | jq -r '.['${N}'] | ["epoch","slot","hash","issued","n_tx","sent","size","leader","fees"] as $keys | [.cbeEpoch , .cbeSlot, .cbeBlkHash, .cbeTimeIssued, .cbeTxNum, .cbeTotalSent.getCoin, .cbeSize, .cbeBlockLead, .cbeFees.getCoin] as $values | $keys, $values | @csv' | {
     OLDIFS=${IFS}
     IFS=','
     read H1 H2 H3 H4 H5 H6 H7 H8 H9
     read EPOCH SLOT BLKHASH ISSUED TXNUM SENT SIZE BLKLEAD FEES
     BLKLEAD=$(echo $BLKLEAD | tr '"' "'")
     BLKHASH=$(echo $BLKHASH | tr '"' "'")
     SENT=$(echo $SENT | tr '"' "'")
     FEES=$(echo $FEES | tr '"' "'")
     echo "INSERT INTO block ("\"pagenr\"", $H1, $H2, $H3, $H4, $H5, $H6, $H7, $H8, $H9) VALUES($PAGENR, $EPOCH, $SLOT, $BLKHASH, to_timestamp($ISSUED), $TXNUM, $SENT, $SIZE, (SELECT leaderid FROM \"leader\" WHERE hash=${BLKLEAD}), $FEES);"
     IFS=${OLDIFS}
   }
done

echo "COMMIT;"
