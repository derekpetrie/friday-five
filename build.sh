#!/bin/bash
# Assembles Friday Five newsletter from template + content fragment
# Usage: ./build.sh YYYY-MM-DD

set -e

DATE="$1"
if [ -z "$DATE" ]; then
  DATE=$(date '+%Y-%m-%d')
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/template"
CONTENT="$SCRIPT_DIR/content.html"
OUTPUT="$SCRIPT_DIR/${DATE}.html"

if [ ! -f "$CONTENT" ]; then
  echo "Error: $CONTENT not found. Write content.html first."
  exit 1
fi

# Build: header + content + footer
{
  sed "s/{{DATE}}/$DATE/g" "$TEMPLATE_DIR/header.html"
  cat "$CONTENT"
  cat "$TEMPLATE_DIR/footer.html"
} > "$OUTPUT"

echo "Built: $OUTPUT"

# Update index.html redirect
cat > "$SCRIPT_DIR/index.html" << EOF
<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<meta http-equiv="refresh" content="0;url=${DATE}.html">
<script>window.location.replace("${DATE}.html");</script>
</head><body style="background:#f9fafb"></body></html>
EOF

echo "Updated index.html -> ${DATE}.html"

# Clean up content fragment
rm -f "$CONTENT"
