#! /usr/bin/env bash
#
# Check if the user provided a folder path as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <folder_path>"
    exit 1
fi

folder_path=$1

# Check if the provided path is a directory
if [ ! -d "$folder_path" ]; then
    echo "Error: $folder_path is not a directory."
    exit 1
fi

# Iterate through the files in the folder and print their names
find "$folder_path" -type f -exec sh -c 'git add "$1" && git commit -m "asdf" --date "$2 days ago"' sh {} "$2" \;

