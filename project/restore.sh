#!/bin/bash

# Script location: $HOME/project/restore
RECYCLE_BIN="$HOME/recyclebin"
RESTORE_INFO="$HOME/.restore.info"

# Function to restore file
restore_file() {
    local recycled_name=$1
    local orig_path_info=$(grep "^$recycled_name:" "$RESTORE_INFO")

    if [ -z "$orig_path_info" ]; then
        echo "Error: File not found in restore info"
        return 1
    fi

    local orig_path=$(echo "$orig_path_info" | cut -d ':' -f 2-)
    local dir_path=$(dirname "$orig_path")

    # Create directory if it doesn't exist
    if [ ! -d "$dir_path" ]; then
        mkdir -p "$dir_path"
    fi

    # Check if file already exists at the original location
    if [ -f "$orig_path" ]; then
        read -p "Do you want to overwrite '$orig_path'? y/n " yn
        case $yn in
            [Yy]*) ;;
            *) return 1;;
        esac
    fi

    mv "$RECYCLE_BIN/$recycled_name" "$orig_path"
    grep -v "^$recycled_name:" "$RESTORE_INFO" > "$RESTORE_INFO.tmp"
    mv "$RESTORE_INFO.tmp" "$RESTORE_INFO"
    echo "File restored to $orig_path"
}

# Error Handling
if [ $# -eq 0 ]; then
    echo "Error: No filename provided"
    exit 1
fi

recycled_name="$1"
if [ ! -f "$RECYCLE_BIN/$recycled_name" ]; then
    echo "Error: File does not exist in recycle bin"
    exit 1
fi

restore_file "$recycled_name"
