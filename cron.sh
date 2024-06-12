#!/bin/bash
set -x

echo "----------------------------"
echo "Script started at: $(date)"

directoryPath="/home/aniket/ludusavi-backup"

/home/aniket/.cargo/bin/ludusavi backup --no-cloud-sync --force --path "$directoryPath" && \
bash "$directoryPath"/backup.sh "$directoryPath"

echo "Script completed at: $(date)"
echo "----------------------------"
