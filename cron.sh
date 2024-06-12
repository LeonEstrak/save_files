#!/bin/bash
set -x

directoryPath="/home/aniket/ludusavi-backup"

/home/aniket/.cargo/bin/ludusavi backup --no-cloud-sync --force --path "$directoryPath" && \
bash "$directoryPath"/backup.sh "$directoryPath"

echo "Script completed at: $(date)"
echo "----------------------------"
