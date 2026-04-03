#!/bin/bash
# Deploy Friday Five to GitHub Pages via GitHub Contents API
# Usage: ./deploy.sh YYYY-MM-DD
# Uses PAT for authentication

set -e

DATE="$1"
if [ -z "$DATE" ]; then
  DATE=$(date '+%Y-%m-%d')
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="derekpetrie/friday-five"
BRIEF_FILE="$SCRIPT_DIR/${DATE}.html"
INDEX_FILE="$SCRIPT_DIR/index.html"
PAT="${GITHUB_PAT:-}"

if [ -z "$PAT" ]; then
  echo "Error: GITHUB_PAT not set"
  exit 1
fi

if [ ! -f "$BRIEF_FILE" ]; then
  echo "Error: $BRIEF_FILE not found. Run build.sh first."
  exit 1
fi

echo "Deploying $DATE issue to $REPO..."

# Upload a file via GitHub Contents API using PAT
upload_file() {
  local local_path="$1"
  local repo_path="$2"
  local message="$3"

  local content
  content=$(base64 < "$local_path" | tr -d '\n')

  # Check if file exists to get its SHA (needed for updates)
  local sha
  sha=$(curl -s -H "Authorization: token $PAT" \
    "https://api.github.com/repos/$REPO/contents/$repo_path" \
    | python3 -c "import sys,json; print(json.load(sys.stdin).get('sha',''))" 2>/dev/null || echo "")

  local payload
  if [ -n "$sha" ]; then
    payload="{\"message\":\"$message\",\"content\":\"$content\",\"sha\":\"$sha\"}"
  else
    payload="{\"message\":\"$message\",\"content\":\"$content\"}"
  fi

  local response
  response=$(curl -s -w "\n%{http_code}" -X PUT \
    -H "Authorization: token $PAT" \
    -H "Content-Type: application/json" \
    "https://api.github.com/repos/$REPO/contents/$repo_path" \
    -d "$payload")

  local http_code
  http_code=$(echo "$response" | tail -1)

  if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
    echo "  Uploaded: $repo_path ($http_code)"
  else
    echo "  FAILED: $repo_path ($http_code)"
    echo "$response" | head -5
    return 1
  fi
}

# Upload the newsletter HTML
upload_file "$BRIEF_FILE" "${DATE}.html" "Friday Five: $DATE"

# Upload updated index.html
upload_file "$INDEX_FILE" "index.html" "Update index -> $DATE"

# Upload assets if they exist and haven't been deployed
if [ -f "$SCRIPT_DIR/assets/style.css" ]; then
  upload_file "$SCRIPT_DIR/assets/style.css" "assets/style.css" "Update stylesheet"
fi

echo "Deploy complete: https://derekpetrie.github.io/friday-five/${DATE}.html"
