#!/usr/bin/bash

# Check the Arguements 
#   a. Path 
#   b. verbose Enable

# Change directory to path 
# looping in the directory checking the file
# create directory based of the file extension 
# move the file to specifc directory 


# Checking the Arguments 
if [[ $# != 1 ]]; then 
    echo "Error paramaters ./organzer.sh <Path of directory>"
    exit 2
fi

# Changing to path directory and listing files.
# Check the Arguments
if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: ./organizer.sh <Path of directory> [verbose]"
    exit 2
fi

# Set verbose mode if the second argument is provided
verbose=0
if [[ $# -eq 2 && $2 == "verbose" ]]; then
    verbose=1
fi

# Changing to path directory and listing files
search_directory="$1"
echo "Changing the directory to $search_directory"
cd "$search_directory" || { echo "Invalid Path"; exit 3; }

# Create Organiser directory if it does not exist
organiser_directory="$search_directory/Organiser"
if [[ ! -d "$organiser_directory" ]]; then
    mkdir "$organiser_directory"
    echo "Created directory: $organiser_directory"
fi

echo "Listing files:"
ls

#Loop through all files in the directory
for file in "$search_directory"/*; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        extension="${filename##*.}"

        # Determine if the file has an extension or not
        if [[ "$filename" == *.* ]]; then
            target_directory="$organiser_directory/$extension"
        else
            target_directory="$organiser_directory/misc"
            extension="misc"
        fi

        # Create the directory based on extension if it does not exist
        if [[ ! -d "$target_directory" ]]; then
            mkdir "$target_directory"
            echo "Created directory: $target_directory"
        fi

        # Move the file to the appropriate directory
        mv "$file" "$target_directory/"
        if [[ $verbose -eq 1 ]]; then
            echo "Moved $filename to $target_directory"
        fi
    fi

done



    