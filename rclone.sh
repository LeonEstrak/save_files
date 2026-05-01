#!/bin/bash

# Function to print script title
print_title() {
    echo "
............................
Rclone Sync to OCI Bucket
............................"
}

# Print the script title
print_title

# Set directory path
directoryPath="$1"

if [ -z "$directoryPath" ]; then
    echo "Error: First Argument should be the directory path"
    exit 1
fi

# Check if rclone is installed
if ! command -v rclone &> /dev/null; then
    echo "Error: rclone is not installed. Please run the setup script first to install rclone."
    exit 1
fi

# Check if rclone is configured for OCI
if ! rclone listremotes | grep -q "oci:"; then
    echo "Error: OCI remote not configured in rclone. Please run 'rclone config' to set up OCI."
    exit 1
fi

echo -e "\n............................"
echo "Starting rclone sync to OCI bucket"
echo "Source: $directoryPath"
echo "Destination: oci:save_files"
echo "Started at: $(date)"
echo "............................"

rclone sync "$directoryPath" oci:save_files --fast-list --tpslimit 5 --progress --stats 30s --verbose

if [ $? -eq 0 ]; then
    echo -e "\n............................"
    echo "Rclone sync completed successfully at: $(date)"
    echo "............................"
else
    echo -e "\n............................"
    echo "Error: Rclone sync failed at: $(date)"
    echo "............................"
    exit 1
fi
