#!/usr/bin/env bash

if [ $# -ne 1 ]; then
  echo "$0 <hash>"
  exit 1
fi

BLKHASH=$1

PAYLOAD=`curl -s https://cardanoexplorer.com/api/blocks/txs/$1`

TXLIST=`echo "${PAYLOAD}" | jq '.Right'`

if [ -z "$TXLIST" ]; then
  echo "No match."
  exit 1
fi

echo "BEGIN TRANSACTION;"

H1="go"
echo "${TXLIST}" | jq -r '.[] | ["hash","issued","suminput","sumoutput"] as $keys | [.ctbId , .ctbTimeIssued, .ctbInputSum.getCoin, .ctbOutputSum.getCoin] as $values | $keys, $values | @csv' | {
  while [ -n "${H1}" ]; do
    OLDIFS=${IFS}
    IFS=','
    read H1 H2 H3 H4
    read TXID ISSUED SUMIN SUMOUT
    if [ -n "${H1}" ]; then 
      TXID=$(echo $TXID | tr '"' "'")
      SUMIN=$(echo $SUMIN | tr '"' "'")
      SUMOUT=$(echo $SUMOUT | tr '"' "'")
      echo "INSERT INTO transaction("\"blockid\"", $H1, $H2, $H3, $H4) VALUES((SELECT blockid FROM \"block\" WHERE hash='${BLKHASH}'), $TXID, to_timestamp($ISSUED), $SUMIN, $SUMOUT);"
      IFS=${OLDIFS}
      ./txs_summary.sh $TXID
    fi
  done
}
 
echo "COMMIT;"
