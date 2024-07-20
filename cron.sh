#!/bin/bash
set -x

echo "----------------------------"
echo "Script started at: $(date)"

directoryPath="/home/aniket/ludusavi-backup"

/home/aniket/.cargo/bin/ludusavi backup --no-cloud-sync --force --path "$directoryPath" && \
python3 "$directoryPath"/generate_readme.py "$directoryPath"
bash "$directoryPath"/git-backup.sh "$directoryPath"

echo "Script completed at: $(date)"
echo "----------------------------"

# Crontab current state
# ➜  ~ crontab -l
# */10 * * * * bash /home/aniket/ludusavi-backup/cron.sh >> /home/aniket/Code_Repository/logs/cron.log
