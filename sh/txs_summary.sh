#!/usr/bin/env bash

if [ $# -ne 1 ]; then
  echo "$0 <hash>"
  exit 1
fi

TXID=$1

source config.sh


PAYLOAD=`curl -s ${EXPLORER_URL}/api/txs/summary/${TXID}`

TX=`echo "${PAYLOAD}" | jq '.Right'`

if [ -z "$TX" ]; then
  echo -n "-- "
  prtRed "$0: No match."
  echo
  exit 1
fi

H1="go"
echo "${TX}" | jq -r '.ctsInputs | .[] | ["addrhash","value"] as $keys | [.[0], .[1].getCoin] as $values | $keys, $values | @csv' | {
  while [ -n "${H1}" ]; do
    OLDIFS=${IFS}
    IFS=','
    read H1 H2
    read ADDRHASH VALUE
    if [ -n "${H1}" ]; then 
      ADDRHASH=$(echo $ADDRHASH | tr '"' "'")
      VALUE=$(echo $VALUE | tr '"' "'")
      echo "INSERT INTO address (hash) VALUES(${ADDRHASH}) ON CONFLICT DO NOTHING;"
      IFS=${OLDIFS}
    fi
  done
}
 
H1="go"
echo "${TX}" | jq -r '.ctsOutputs | .[] | ["addrhash","value"] as $keys | [.[0], .[1].getCoin] as $values | $keys, $values | @csv' | {
  while [ -n "${H1}" ]; do
    OLDIFS=${IFS}
    IFS=','
    read H1 H2
    read ADDRHASH VALUE
    if [ -n "${H1}" ]; then 
      ADDRHASH=$(echo $ADDRHASH | tr '"' "'")
      VALUE=$(echo $VALUE | tr '"' "'")
      echo "INSERT INTO address (hash) VALUES(${ADDRHASH}) ON CONFLICT DO NOTHING;"
      IFS=${OLDIFS}
    fi
  done
}

#echo "BEGIN TRANSACTION;"

H1="go"
echo "${TX}" | jq -r '.ctsInputs | .[] | ["addrhash","value"] as $keys | [.[0], .[1].getCoin] as $values | $keys, $values | @csv' | {
  while [ -n "${H1}" ]; do
    OLDIFS=${IFS}
    IFS=','
    read H1 H2
    read ADDRHASH VALUE
    if [ -n "${H1}" ]; then 
      ADDRHASH=$(echo $ADDRHASH | tr '"' "'")
      VALUE=$(echo $VALUE | tr '"' "'")
      echo "INSERT INTO trxaddrinputrel ("\"trxid\"", "\"addrid\"", $H2) VALUES((SELECT trxid FROM \"transaction\" WHERE hash='${TXID}'), (SELECT addrid FROM \"address\" WHERE hash=${ADDRHASH}), $VALUE);"
      IFS=${OLDIFS}
    fi
  done
}
 
H1="go"
echo "${TX}" | jq -r '.ctsOutputs | .[] | ["addrhash","value"] as $keys | [.[0], .[1].getCoin] as $values | $keys, $values | @csv' | {
  while [ -n "${H1}" ]; do
    OLDIFS=${IFS}
    IFS=','
    read H1 H2
    read ADDRHASH VALUE
    if [ -n "${H1}" ]; then 
      ADDRHASH=$(echo $ADDRHASH | tr '"' "'")
      VALUE=$(echo $VALUE | tr '"' "'")
      echo "INSERT INTO trxaddroutputrel ("\"trxid\"", "\"addrid\"", $H2) VALUES((SELECT trxid FROM \"transaction\" WHERE hash='${TXID}'), (SELECT addrid FROM \"address\" WHERE hash=${ADDRHASH}), $VALUE);"
      IFS=${OLDIFS}
    fi
  done
}

#echo "COMMIT;"
