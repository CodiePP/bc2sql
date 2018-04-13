#!/bin/sh

RED="\033[31m"
GREEN="\033[32m"
BROWN="\033[33m"
BLUE="\033[34m"
PURPLE="\033[35m"
CYAN="\033[36m"
LIGRAY="\033[37m"

Closing="\033[0m"

function prtRed {
  echo -n -e ${RED} $* ${Closing}
}

function prtGreen {
  echo -n -e ${GREEN} $* ${Closing}
}

function prtBrown {
  echo -n -e ${BROWN} $* ${Closing}
}

function prtBlue {
  echo -n -e ${BLUE} $* ${Closing}
}

function prtPurple {
  echo -n -e ${PURPLE} $* ${Closing}
}

function prtCyan {
  echo -n -e ${CYAN} $* ${Closing}
}

function prtLightGray {
  echo -n -e ${LIGRAY} $* ${Closing}
}

