
#!/bin/bash

# Initialize a git repository
git init

# Get the current folder name
folderName=$(basename "$(pwd)")

# Create and switch to a new branch
git checkout -b "$folderName"

# Add all files in the current directory and subdirectories
git add .

# Commit the changes
git commit -m "Initial commit"

# Set the remote origin
git remote add origin https://github.com/LeonEstrak/save_files.git

# Push the new branch to remote
git push -u origin "$folderName"

# Prompt to press Enter before exiting
read -rp "Press Enter to exit..."

