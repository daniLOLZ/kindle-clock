#!/bin/sh

### Flags
while getopts "d:" option; do
  case "$option" in
  d) DEBUG=${OPTARG} ;;
  esac
done

fetch_code

bash setup.sh -d $DEBUG
rc=$?
if [[ "$rc" != "0" ]]; then
  exit
fi

while true; do

  fetch_code

  bash loop.sh -d $DEBUG

  if [ "$DEBUG" = "1" ]; then
    exit
  fi

done
