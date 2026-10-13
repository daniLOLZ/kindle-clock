#!/bin/sh

LOOP_CODE="https://raw.githubusercontent.com/daniLOLZ/kindle-clock/refs/heads/feat/tasknotes/loop.sh"
PREFERENCES_CODE="https://raw.githubusercontent.com/daniLOLZ/kindle-clock/refs/heads/feat/tasknotes/preferences.json"

### Flags
while getopts "d:" option; do
  case "$option" in
  d) DEBUG=${OPTARG} ;;
  esac
done

fetch_code() {
  # Tried doing Cache-Control but github raw pages force max-age=300
  curl $LOOP_CODE -o "./loop.sh"
  curl $PREFERENCES_CODE -o "./preferences.json"
}

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
