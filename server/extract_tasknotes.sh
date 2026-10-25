#!/usr/bin/env bash
set -euo pipefail

# ── Setup ────────────────────────────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
	echo "Usage: $0 /path/to/vault [output.json]" >&2
	exit 1
fi

vault_directory="$1"
output_file="${2:-}"

log() {
	echo "[extract_tasknotes] $*"
}

log "Starting extraction from '$vault_directory'"

# ── Dependency check ─────────────────────────────────────────────────────────

for dependency in yq jq find; do
	if ! command -v "$dependency" &>/dev/null; then
		echo "Error: required command '$dependency' not found in PATH." >&2
		exit 1
	fi
done

if [[ ! -d "$vault_directory" ]]; then
	echo "Error: '$vault_directory' is not a directory." >&2
	exit 1
fi

# ── Helpers ──────────────────────────────────────────────────────────────────

frontmatter_from() {
	sed -n '/^---$/,/^---$/p' "$1" | sed '1d;$d'
}

is_task_note() {
	local frontmatter="$1"
	[[ $(printf '%s\n' "$frontmatter" | yq '.taskNote') == "true" ]]
}

priority_from() {
	printf '%s\n' "$1" | yq '.priority' | tr -d '"'
}

status_from() {
	printf '%s\n' "$1" | yq '.status' | tr -d '"'
}

note_name_from() {
	basename "$1" .md
}

validate_priority() {
	local priority="$1"
	local markdown_file="$2"
	case "$priority" in
	none | lowest | low | medium | high | highest) ;;
	*)
		errors+=("Invalid priority '$priority' in $markdown_file")
		;;
	esac
}

validate_status() {
	local status="$1"
	local markdown_file="$2"
	case "$status" in
	open | next-action | cancelled | done | archived | blocked) ;;
	*)
		errors+=("Invalid status '$status' in $markdown_file")
		;;
	esac
}

# ── Extraction ───────────────────────────────────────────────────────────────

errors=()

task_notes_json=$(find "$vault_directory" -type f -name '*.md' |
	while IFS= read -r markdown_file; do

		frontmatter=$(frontmatter_from "$markdown_file")
		[[ -z "$frontmatter" ]] && continue
		is_task_note "$frontmatter" || continue

		note_name=$(note_name_from "$markdown_file")
		priority=$(priority_from "$frontmatter")
		status=$(status_from "$frontmatter")
		validate_priority "$priority" "$markdown_file"
		validate_status "$status" "$markdown_file"

		printf '{"name": %s, "priority": %s, "status": %s}\n' "$(jq -Rn --arg name "$note_name" '$ARGS.named.name')" "$(jq -Rn --arg priority "$priority" '$ARGS.named.priority')" "$(jq -Rn --arg status "$status" '$ARGS.named.status')"

	done |
	jq -n '[inputs] | to_entries | map(.value + {id: (.key + 1)})')

if [[ ${#errors[@]} -gt 0 ]]; then
	for error in "${errors[@]}"; do echo "ERROR: $error" >&2; done
	exit 1
fi

# ── Output ───────────────────────────────────────────────────────────────────

if [[ -n "$output_file" ]]; then
	mkdir -p "$(dirname "$output_file")"
	printf '%s\n' "$task_notes_json" >"$output_file"
	log "Wrote $task_notes_json to '$output_file'"
else
	printf '%s\n' "$task_notes_json"
fi

log "Finished extraction."
