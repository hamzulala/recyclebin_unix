#!/bin/bash

# Script location: $HOME/project/recycle
# Recycle Bin Directory
RECYCLE_BIN="$HOME/recyclebin"
RESTORE_INFO="$HOME/.restore.info"

# Create recyclebin directory if it doesn't exist
mkdir -p "$RECYCLE_BIN"

# Create .restore.info if it doesn't exist
touch "$RESTORE_INFO"

# Function to handle file recycling
recycle_file() {
    local file=$1
    local inode=$(ls -i "$file" | cut -d ' ' -f 1)
    local dest="$RECYCLE_BIN/${file}_$inode"
    mv "$file" "$dest"
    echo "${file}_$inode:$(realpath "$file")" >> "$RESTORE_INFO"
}

# Error Handling
if [ $# -eq 0 ]; then
    echo "Error: No filename provided"
    exit 1
fi

for file in "$@"; do
    if [ ! -f "$file" ]; then
        echo "Error: '$file' is not a file or does not exist"
        continue
    elif [ "$(realpath "$file")" = "$(realpath "$0")" ]; then
        echo "Attempting to delete recycle �~@~S operation aborted"
        exit 1
    else
        recycle_file "$file"
    fi
    done