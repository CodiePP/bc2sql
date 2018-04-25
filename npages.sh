#!/usr/bin/env bash

source config.sh

PAYLOAD=`curl -s ${EXPLORER_URL}/api/blocks/pages/total`

if [ -n "${PAYLOAD}" ]; then
  echo ${PAYLOAD} | jq '.Right'
else
  echo "problem .."
fi

