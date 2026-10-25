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
  echo "$(date) Starting to fetch new code..." >>logs/curl_code.log
  loop_sha_before=$(sha256sum loop.sh)
  curl $LOOP_CODE -v -o "./loop.sh" 2>>logs/curl_code.log
  loop_sha_after=$(sha256sum loop.sh)
  if [[ "$loop_sha_before" != "$loop_sha_after" ]]; then
    echo "Updates to loop.sh detected" 2>>logs/curl_code.log
  fi
  preferences_sha_before=$(sha256sum ./preferences.json)
  curl $PREFERENCES_CODE -v -o "./preferences.json" 2>>logs/curl_code.log
  preferences_sha_after=$(sha256sum ./preferences.json)
  if [[ "$preferences_sha_before" != "$preferences_sha_after" ]]; then
    echo "Updates to preferences.sh detected" 2>>logs/curl_code.log
  fi
  echo "Finished fetching new code" >>logs/curl_code.log
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
