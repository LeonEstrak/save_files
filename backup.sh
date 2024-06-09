#!/bin/bash

# Function to print script title
print_title() {
    echo "
............................
Git Backup Save Files
............................"
}

# Print the script title
print_title

# Set directory path
directoryPath="$1"

# Change the working directory
cd "$directoryPath" || { echo "Error: Directory not found"; exit 1; }

echo -e "\n............................"
echo "Performing back up at $directoryPath"
echo "............................"

# Check for changes
changes=$(git status --porcelain)

if [ -n "$changes" ]; then
    git status
    echo -e "\n............................\n"
    echo -e "\nThere are changes to commit.\n"
    echo -e "\n............................\n"
else
    echo -e "\nNo changes to commit."
    exit
fi

# Get the current timestamp
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

# Add all modified or newly added files to the staging area
echo -e "\nAdding changes to the staging area..."
git add -A
echo "Changes added to the staging area.\n"

# Commit the changes with the timestamp as the commit message
echo -e "\nCommitting changes with timestamp: $timestamp..."
git commit -m "Changes as of $timestamp"
echo "Changes committed.\n"

# Push the changes
echo -e "\nPushing changes to the remote repository..."
git push
echo "Changes pushed to the remote repository.\n"

# Sleep for 3 seconds
echo -e "\nScript execution completed. Sleeping for 3 seconds..."
sleep 3
echo "Sleep completed. Exiting script."

