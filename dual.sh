#!/bin/bash

XRANDR="xrandr"
PRIMARY="eDP1"
CMD="${XRANDR}"
declare -A VOUTS
eval VOUTS=$(${XRANDR}|awk 'BEGIN {printf("(")} /^\S.*connected/{printf("[%s]=%s ", $1, $2)} END{printf(")")}')
PRIMARY_MODE="1366x768"

find_mode() {
  echo $(${XRANDR} |grep ${1} -A1|awk '{FS="[ x]"} /^\s/{printf("WIDTH=%s\nHEIGHT=%s", $4,$5)}')
}

xrandr_params_for() {
  echo "${1} ${2}"
  if [ "${1}" == ${PRIMARY} ]
  then
    return 1
  elif [ "${2}" == 'connected' ]
  then
    eval $(find_mode ${1})  #sets ${WIDTH} and ${HEIGHT}
    MODE="${WIDTH}x${HEIGHT}"
    echo "${MODE}"
    CMD="${CMD} --output ${1} --mode ${MODE} --left-of ${PRIMARY}"
    return 0
  else
    CMD="${CMD} --output ${1} --off"
    return 1
  fi
}

for VOUT in ${!VOUTS[*]}
do
  xrandr_params_for ${VOUT} ${VOUTS[${VOUT}]}
done
set -x
CMD="${CMD} --output ${PRIMARY} --mode ${PRIMARY_MODE}"
${CMD}
set +x
