#!/bin/bash
PREFERENCES_FILE="./preferences.json"
TODOIST_LABEL="$(jq '.todoist_label' $PREFERENCES_FILE | sed -e 's/^"//g' -e 's/"$//g')"
curl -f -s -m 5 https://api.todoist.com/api/v1/sync -H "Authorization: Bearer $(cat api_key.txt)" -d resource_types='["items"]' |
  jq --arg TODOIST_LABEL $TODOIST_LABEL '.items | .[] | {content: .content, label: .labels[], priority: .priority} | if .label == $TODOIST_LABEL then . else empty end | .content,.priority' |
  sed -e 's/^"//g' -e 's/"$//g'
