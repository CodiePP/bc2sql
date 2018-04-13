#!/usr/bin/env bash

PAYLOAD=`curl -s https://cardanoexplorer.com/api/blocks/pages/total`

if [ -n "${PAYLOAD}" ]; then
  echo ${PAYLOAD} | jq '.Right'
else
  echo "problem .."
fi

