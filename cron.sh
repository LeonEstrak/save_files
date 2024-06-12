#!/bin/bash
set -x

echo "\n----------------------------"
echo "Script started at: $(date)\n"

directoryPath="/home/aniket/ludusavi-backup"

/home/aniket/.cargo/bin/ludusavi backup --no-cloud-sync --force --path "$directoryPath" && \
bash "$directoryPath"/backup.sh "$directoryPath"

echo "\nScript completed at: $(date)"
echo "----------------------------\n"
