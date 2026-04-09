#!/bin/bash
# Optimize images for web delivery
# Requires: ImageMagick (brew install imagemagick)
set -e

DIR="$(cd "$(dirname "$0")" && pwd)/images"

if ! command -v convert &>/dev/null; then
  echo "ImageMagick not found. Install with: brew install imagemagick"
  exit 1
fi

echo "Optimizing images in $DIR..."
for img in "$DIR"/*.jpg "$DIR"/*.JPG; do
  [ -f "$img" ] || continue
  size=$(stat -f%z "$img" 2>/dev/null || stat -c%s "$img" 2>/dev/null)
  if [ "$size" -gt 500000 ]; then
    echo "  Resizing: $(basename "$img") ($(( size / 1024 ))KB)"
    convert "$img" -resize "1920x1920>" -quality 82 -strip "$img"
  fi
done

echo "Done! Images optimized for web."
