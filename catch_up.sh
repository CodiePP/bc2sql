#!/usr/bin/env bash

source config.sh

NPAGES=`./sh/npages.sh`
NPAGES=`./bin/npages`
if [ -z "${NPAGES}" -o $NPAGES -lt 111 ]; then
  echo -n "-- "
  prtRed "$0: cannot query explorer for total number of pages."
  exit 1
fi

q="SELECT MAX(pagenr) FROM page;"
r=$(psql -At -q -c "${q}")
if [ -z "${r}" ]; then
  echo -n "-- "
  prtRed "$0: cannot query db."
  exit 1
fi

STARTPAGE=$((r + 1))
ENDPAGE=$((NPAGES - 1))

echo "from ${STARTPAGE} to ${ENDPAGE}"

# choose one of:
# the 'stack' script
#./get_pages.hs ${STARTPAGE} ${ENDPAGE}
# or:
# the compiled program
./bin/get-pages ${STARTPAGE} ${ENDPAGE}

