#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: No prefix provided."
    echo "Usage: ./convert-heic-to-png.sh <prefix> <dir>"
    echo "Example: ./convert-heic-to-png.sh nifeilz-l6- ./"
    exit 1
fi

PREFIX="$1"

if [ -z "$2" ]; then
    echo "Error: No working directory provided."
    echo "Usage: ./convert-heic-to-png.sh <prefix> <dir>"
    echo "Example: ./convert-heic-to-png.sh nifeilz-l6- ./"
    exit 1
fi

WORKING_DIR="$2"

mkdir -p "${WORKING_DIR}"/converted_pngs

N=1

shopt -s nocaseglob nullglob

echo "Starting conversion with prefix: '${PREFIX}'..."

for file in "${WORKING_DIR}"/*IMG_*.HEIC; do
    output_name="converted_pngs/${PREFIX}${N}.png"

    if command -v sips &> /dev/null; then
        echo "Converting: $file -> ${PREFIX}${N}.png"
        sips -s format png "$file" --out "$WORKING_DIR/$output_name" > /dev/null
        
    elif command -v magick &> /dev/null; then
        echo "Converting: $file -> ${PREFIX}${N}.png"
        magick "$file" "$WORKING_DIR/$output_name"
        
    else
        echo "Error: Conversion tool not found."
        echo "If you are on Linux/Windows, please install ImageMagick."
        exit 1
    fi

    ((N++))
done

echo "Done! Successfully converted $((N-1)) images."