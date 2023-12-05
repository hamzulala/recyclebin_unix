#!/bin/bash
#Script location: $HOME/project/restore
RECYCLE_BIN="$HOME/recyclebin"
RESTORE_INFO="$HOME/.restore.info"

# Function to restore file
restore_file() {
    local file=$1
    local orig_path=$(grep "^$file:" "$RESTORE_INFO" | cut -d ':' -f 2-)
    if [ -z "$orig_path" ]; then
        echo "Error: File not found in restore info"
        return
    fi
    if [ -f "$orig_path" ]; then
        read -p "Do you want to overwrite '$orig_path'? y/n " yn
        case $yn in
            [Yy]*) ;;
            *) return;;
        esac
    fi
    mv "$RECYCLE_BIN/$file" "$orig_path"
    grep -v "^$file:" "$RESTORE_INFO" > "$RESTORE_INFO.tmp"
    mv "$RESTORE_INFO.tmp" "$RESTORE_INFO"
}

# Error Handling
if [ $# -eq 0 ]; then
    echo "Error: No filename provided"
    exit 1
fi

if [ ! -f "$RECYCLE_BIN/$1" ]; then
    echo "Error: File does not exist in recycle bin"
    exit 1
fi

restore_file "$1"
