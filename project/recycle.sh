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
    local interactive=$2
    local verbose=$3

    if [ ! -f "$file" ] && [ ! -d "$file" ]; then
        echo "Error: '$file' is not a file or does not exist"
        return
    fi

    if [[ $interactive == 1 ]]; then
        read -p "Recycle '$file'? " yn
        case $yn in
            [Yy]*) ;;
            *) return;;
        esac
    fi

    if [ "$(realpath "$file")" = "$(realpath "$0")" ]; then
        echo "Attempting to delete recycle - operation aborted"
        return
    fi

    local inode=$(ls -i "$file" | awk '{print $1}')
    local dest="$RECYCLE_BIN/${file##*/}_$inode"
    mv "$file" "$dest"
    echo "${file##*/}_$inode:$(realpath "$file")" >> "$RESTORE_INFO"

    if [[ $verbose == 1 ]]; then
        echo "Recycled '$file'"
    fi
}

# Function to recursively recycle files
recycle_directory() {
    local dir=$1
    for file in "$dir"/*; do
        if [ -f "$file" ]; then
            recycle_file "$file" $interactive_mode $verbose_mode
        elif [ -d "$file" ]; then
            recycle_directory "$file"
        fi
    done
    rmdir "$dir"
}

# Main loop - handle options and files
interactive_mode=0
verbose_mode=0
recursive_mode=0

# Process combined -iv or -vi flag
if [ "$1" == "-iv" ] || [ "$1" == "-vi" ]; then
    interactive_mode=1
    verbose_mode=1
    shift
fi

# Process individual flags and files
while (( "$#" )); do
    case "$1" in
        -i)
            interactive_mode=1
            shift
            ;;
        -v)
            verbose_mode=1
            shift
            ;;
        -r)
            recursive_mode=1
            shift
            ;;
        --)
            shift
            break
            ;;
        -*|--*=) # unsupported flags
            echo "Error: Unsupported flag $1" >&2
            exit 1
            ;;
        *)
            if [ $recursive_mode -eq 1 ] && [ -d "$1" ]; then
                recycle_directory "$1"
            else
                recycle_file "$1" $interactive_mode $verbose_mode
            fi
            shift
            ;;
    esac
done
