#!/bin/bash

# Define paths and URLs.
SERVICE_FILE="./ludusavi.backup.service"
TIMER_FILE="./ludusavi.backup.timer"
LUDUSAVI_PATH="/home/aniket/.local/bin/ludusavi"
LUDUSAVI_REPO="mtkennerly/ludusavi"

# Check if rclone is installed
if ! command -v rclone &> /dev/null; then
  echo "Rclone not found. Downloading and installing rclone..."

  # Create the target directory if it doesn't exist
  mkdir -p ~/.local/bin

  # Get the latest rclone version for Linux AMD64
  RCLONE_VERSION=$(curl -s https://api.github.com/repos/rclone/rclone/releases/latest | jq -r '.tag_name')
  
  if [ -z "$RCLONE_VERSION" ] || [ "$RCLONE_VERSION" = "null" ]; then
    echo "Error: Could not retrieve rclone version from GitHub API."
    exit 1
  fi

  # Download URL for Linux AMD64
  RCLONE_DOWNLOAD_URL="https://github.com/rclone/rclone/releases/download/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-amd64.zip"
  
  echo "Downloading rclone version ${RCLONE_VERSION}..."

  # Download rclone
  curl -L "$RCLONE_DOWNLOAD_URL" -o rclone.zip

  # Check if the download was successful
  if [ $? -ne 0 ]; then
    echo "Error downloading rclone."
    exit 1
  fi

  # Extract rclone
  unzip -q rclone.zip

  # Move the executable to ~/.local/bin
  mv rclone-${RCLONE_VERSION}-linux-amd64/rclone ~/.local/bin/rclone

  # Remove the archive and extracted directory
  rm -rf rclone.zip rclone-${RCLONE_VERSION}-linux-amd64

  # Make rclone executable
  chmod +x ~/.local/bin/rclone

  # Verify the installation was successful
  if [ -f ~/.local/bin/rclone ] && [ -x ~/.local/bin/rclone ]; then
    echo "Rclone downloaded and installed to ~/.local/bin/rclone"
    echo "Please run 'rclone config' to configure OCI remote before using the backup system. Exiting..."
    exit 0
  else
    echo "Error: Rclone installation failed. Binary not found or not executable."
    exit 1
  fi
fi

# Get the latest release download URL using the GitHub API.
LUDUSAVI_DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/$LUDUSAVI_REPO/releases/latest" | jq -r '.assets[] | select(.name | endswith("-linux.tar.gz")) | .browser_download_url')

# Check if the download URL was retrieved successfully.
if [ -z "$LUDUSAVI_DOWNLOAD_URL" ]; then
  echo "Error: Could not retrieve Ludusavi download URL from GitHub API."
  exit 1
fi

# Check if Ludusavi is installed.
if ! command -v "$LUDUSAVI_PATH" &> /dev/null; then
  echo "Ludusavi not found. Downloading..."

  # Create the target directory if it doesn't exist.
  mkdir -p "$(dirname "$LUDUSAVI_PATH")"

  # Download Ludusavi.
  curl -L "$LUDUSAVI_DOWNLOAD_URL" -o ludusavi.tar.gz

  # Check if the download was successful.
  if [ $? -ne 0 ]; then
    echo "Error downloading Ludusavi."
    exit 1
  fi

  # Extract Ludusavi.
  tar -xzf ludusavi.tar.gz

  # Move the executable to the desired location
  mv ludusavi "$LUDUSAVI_PATH"

  # Remove the archive.
  rm ludusavi.tar.gz

  # Make Ludusavi executable.
  chmod +x "$LUDUSAVI_PATH"

  echo "Ludusavi downloaded and installed."
fi

# Check if the service and timer files exist.
if [ ! -f "$SERVICE_FILE" ]; then
  echo "Error: Service file '$SERVICE_FILE' not found."
  exit 1
fi

if [ ! -f "$TIMER_FILE" ]; then
  echo "Error: Timer file '$TIMER_FILE' not found."
  exit 1
fi

# Create the user's systemd directory if it doesn't exist.
mkdir -p ~/.config/systemd/user/
mkdir -p ~/.config/ludusavi/

# Hardlink service/timer and ludusavi config so edits in save_files/ are immediately reflected.
ln -f "$SERVICE_FILE" ~/.config/systemd/user/ludusavi.backup.service
ln -f "$TIMER_FILE" ~/.config/systemd/user/ludusavi.backup.timer
ln -f "$(dirname "$SERVICE_FILE")/ludusavi.config.yaml" ~/.config/ludusavi/config.yaml

# Reload the systemd user manager to recognize the new files.
systemctl --user daemon-reload

# Enable and start the timer.
systemctl --user enable ludusavi.backup.timer
systemctl --user start ludusavi.backup.timer

# Check the status of the timer.
systemctl --user status ludusavi.backup.timer

echo "Ludusavi service/timer has been installed and enabled in ~/.config/systemd/user/."
