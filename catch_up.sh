#!/usr/bin/env bash

source config.sh

NPAGES=`./npages.sh`
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

for P in `seq ${STARTPAGE} ${ENDPAGE}`; do
  prtBlue "${P}  "
  ./get_page.sh ${P} | psql -q -d ${PGDATABASE} --
done

