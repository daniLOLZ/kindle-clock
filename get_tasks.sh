PREFERENCES_FILE="./preferences.json"
TODOIST_LABEL="$(jq -r '.todoist_label' $PREFERENCES_FILE)"
mkdir -p temp
curl -f -s -m 5 https://api.todoist.com/api/v1/sync -H "Authorization: Bearer $(cat api_key.txt)" -d resource_types='["items"]' >temp/todoist_data.json
jq --arg TODOIST_LABEL "KINDLE" '[.items | .[] | {content, label: .labels[], priority, id} | if .label == $TODOIST_LABEL then {content, priority, id} else empty end] ' temp/todoist_data.json >temp/relevant_tasks.json
jq '[[.items | .[] | {parent_id: .parent_id, content: .content}] | group_by(.parent_id) | .[] | {id: .[0].parent_id, children: length}]' temp/todoist_data.json >temp/parent_info.json
jq -r -s '[.[] | .[] ] | group_by(.id) | .[] | {content: .[0].content, priority: .[0].priority, id: .[0].id, children: .[1].children} | if .content != null then . else empty end | if .children == null then {content, priority, id, children: 0} else . end | .content, .priority, .children' temp/relevant_tasks.json temp/parent_info.json
rm temp/*
