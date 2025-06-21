#!/bin/bash
curl -f -s -m 5 https://api.todoist.com/api/v1/sync -H "Authorization: Bearer $(cat api_key.txt)" -d resource_types='["items"]' |
  jq '.items | .[] | {content: .content, label: .labels[], priority: .priority} | if .label == "KINDLE" then . else empty end | .content,.priority' |
  sed -e 's/^"//g' -e 's/"$//g'
