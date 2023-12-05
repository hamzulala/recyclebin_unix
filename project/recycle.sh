#!/bin/bash

# Script location: $HOME/project/recycle
# Recycle Bin Directory
RECYCLE_BIN="$HOME/recyclebin" # Change this to your recycle bin directory 
RESTORE_INFO="$HOME/.restore.info" # Change this to your restore info file

# Create recyclebin directory if it doesn't exist
mkdir -p "$RECYCLE_BIN" # -p flag creates parent directories if they don't exist

# Create .restore.info if it doesn't exist
touch "$RESTORE_INFO" # Creates empty file if it doesn't exist

# Function to handle file recycling
recycle_file() {
    local file=$1 # $1 is the first argument passed to the function
    local interactive=$2 # $2 is the second argument passed to the function
    local verbose=$3 # $3 is the third argument passed to the function

    if [ ! -f "$file" ] && [ ! -d "$file" ]; then # Check if file exists
        echo "Error: '$file' is not a file or does not exist" # Print error message
        return # Exit function
    fi

    if [[ $interactive == 1 ]]; then # Check if interactive mode is on
        read -p "Recycle '$file'? " yn # Prompt user for confirmation
        case $yn in # Case statement to handle user input
            [Yy]*) ;; # Do nothing if user input is y or Y
            *) return;; # Exit function if user input is anything else
        esac # End case statement
    fi

    if [ "$(realpath "$file")" = "$(realpath "$0")" ]; then # Check if file is the same as the script
        echo "Attempting to delete recycle - operation aborted" # Print error message
        return # Exit function
    fi

    local inode=$(ls -i "$file" | awk '{print $1}') # Get inode of file
    local dest="$RECYCLE_BIN/${file##*/}_$inode" # Create destination path
    mv "$file" "$dest" # Move file to destination
    echo "${file##*/}_$inode:$(realpath "$file")" >> "$RESTORE_INFO" # Write to restore info

    if [[ $verbose == 1 ]]; then # Check if verbose mode is on
        echo "Recycled '$file'" # Print verbose message
    fi
}

# Function to recursively recycle files
recycle_directory() { 
    local dir=$1 # $1 is the first argument passed to the function
    for file in "$dir"/*; do # Loop through files in directory
        if [ -f "$file" ]; then # Check if file is a regular file
            recycle_file "$file" $interactive_mode $verbose_mode # Recycle file
        elif [ -d "$file" ]; then # Check if file is a directory
            recycle_directory "$file" # Recursively recycle directory
        fi
    done
    rmdir "$dir" # Remove directory
}

# Main loop - handle options and files
interactive_mode=0 # Set interactive mode to off
verbose_mode=0 # Set verbose mode to off
recursive_mode=0 # Set recursive mode to off

# Process combined -iv or -vi flag
if [ "$1" == "-iv" ] || [ "$1" == "-vi" ]; then # Check if first argument is -iv or -vi
    interactive_mode=1 
    verbose_mode=1 # Set interactive and verbose mode to on
    shift # Shift arguments to the left
fi

# Process individual flags and files
while (( "$#" )); do # Loop through arguments
    case "$1" in # Case statement to handle arguments
        -i)
            interactive_mode=1 # Set interactive mode to on
            shift # Shift arguments to the left
            ;;
        -v)
            verbose_mode=1 # Set verbose mode to on
            shift
            ;;
        -r)
            recursive_mode=1 # Set recursive mode to on
            shift
            ;;
        --) # End of all options
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
