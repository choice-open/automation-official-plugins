#!/bin/bash
set -euo pipefail

BASE_SHA="$1"
HEAD_SHA="$2"
PLUGINS_DIR="plugins"

# Get changed files in plugins directory
CHANGED_FILES=$(git diff --name-only --diff-filter=ACDMR "${BASE_SHA}" "${HEAD_SHA}" | grep "^${PLUGINS_DIR}/" || true)

if [ -z "$CHANGED_FILES" ]; then
	echo "No files changed in ${PLUGINS_DIR}/ directory"
	exit 0
fi

# Extract unique directories from changed files
# Only consider files in subdirectories (at least 2 levels deep)
DIRECTORIES=$(echo "$CHANGED_FILES" | sed "s|^${PLUGINS_DIR}/||" | grep "/" | cut -d'/' -f1 | sort -u)

if [ -z "$DIRECTORIES" ]; then
	echo "Error: Changed files must be in a plugin subdirectory (e.g., plugins/plugin-name/...)"
	echo "Files in plugins/ root directory are not allowed"
	exit 1
fi

# Count unique directories
DIR_COUNT=$(echo "$DIRECTORIES" | wc -l | tr -d ' ')

if [ "$DIR_COUNT" -gt 1 ]; then
	echo "Error: PR involves multiple plugin directories:"
	echo "$DIRECTORIES" | sed 's/^/  - /'
	exit 1
fi

TARGET_DIR="${PLUGINS_DIR}/$(echo "$DIRECTORIES" | head -n1)"

# Verify target directory exists
if [ ! -d "$TARGET_DIR" ]; then
	echo "Error: Target directory '$TARGET_DIR' does not exist"
	exit 1
fi

# Verify all changed files are within the target directory
while IFS= read -r file; do
	if [[ ! "$file" =~ ^${TARGET_DIR}/ ]]; then
		echo "Error: File '$file' is outside target directory '$TARGET_DIR'"
		exit 1
	fi
done <<<"$CHANGED_FILES"

echo "Target directory: ${TARGET_DIR}"

# Function to extract version from project files
extract_version() {
	local dir="$1"
	local sha="$2"
	
	# Try npm project (package.json)
	if git show "${sha}:${dir}/package.json" &>/dev/null; then
		git show "${sha}:${dir}/package.json" | sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1
	# Try elixir project (mix.exs)
	elif git show "${sha}:${dir}/mix.exs" &>/dev/null; then
		git show "${sha}:${dir}/mix.exs" | sed -n 's/.*version:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1
	else
		echo ""
	fi
}

# Extract versions from both base and head
BASE_VERSION=$(extract_version "$TARGET_DIR" "$BASE_SHA")
HEAD_VERSION=$(extract_version "$TARGET_DIR" "$HEAD_SHA")

if [ -z "$HEAD_VERSION" ]; then
	echo "Error: Cannot find version in package.json or mix.exs in $TARGET_DIR"
	exit 1
fi

echo "Base version: ${BASE_VERSION:-<none>}"
echo "Head version: ${HEAD_VERSION}"

# Check if version was updated in this PR
if [ -n "$BASE_VERSION" ] && [ "$BASE_VERSION" = "$HEAD_VERSION" ]; then
	echo "Error: Version not updated in this PR"
	echo "Current version: $HEAD_VERSION"
	exit 1
fi

# Upload to S3
S3_BUCKET="${S3_BUCKET:-}"
S3_PREFIX="${S3_PREFIX:-plugins/}"

if [ -z "$S3_BUCKET" ]; then
	echo "Error: S3_BUCKET environment variable is not set"
	exit 1
fi

PLUGIN_NAME="${TARGET_DIR#${PLUGINS_DIR}/}"
S3_PATH="s3://${S3_BUCKET}/${S3_PREFIX}${PLUGIN_NAME}_${HEAD_VERSION}"

echo "Uploading ${TARGET_DIR} to ${S3_PATH}"

aws s3 sync "${TARGET_DIR}" "${S3_PATH}" --delete

echo "Upload completed successfully"
