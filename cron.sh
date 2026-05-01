#!/bin/bash
set -x

echo "----------------------------"
echo "Script started at: $(date)"

directoryPath="/home/aniket/save_files"
gameBackupsPath="$directoryPath/game_backups"

LUDUSAVI_OK=false
RCLONE_OK=false
ERRORS=""

# Ludusavi backup
if /home/aniket/.local/bin/ludusavi backup --no-cloud-sync --force --path "$gameBackupsPath" --format zip --compression zstd --full-limit 5; then
    LUDUSAVI_OK=true
else
    ERRORS="ludusavi backup failed"
fi

# Generate README
python3 "$directoryPath/generate_readme.py" "$directoryPath"

# Rclone sync
if bash "$directoryPath/rclone.sh" "$gameBackupsPath"; then
    RCLONE_OK=true
else
    ERRORS="${ERRORS:+$ERRORS; }rclone sync failed"
fi

# Write transparency files
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
GAME_COUNT=$(find "$gameBackupsPath" -maxdepth 1 -mindepth 1 -type d | wc -l)
TOTAL_SIZE=$(du -sh "$gameBackupsPath" 2>/dev/null | cut -f1)

cat > "$directoryPath/backup_status.json" << EOF
{
  "last_run": "$TIMESTAMP",
  "games_backed_up": $GAME_COUNT,
  "total_size": "$TOTAL_SIZE",
  "ludusavi_ok": $LUDUSAVI_OK,
  "rclone_synced": $RCLONE_OK,
  "errors": "$ERRORS"
}
EOF

echo "| $TIMESTAMP | $GAME_COUNT games | $TOTAL_SIZE | ludusavi: $LUDUSAVI_OK | rclone: $RCLONE_OK |" >> "$directoryPath/backup_log.md"

# Git commit (tracks README, status files, scripts — game_backups/ is gitignored)
bash "$directoryPath/git-backup.sh" "$directoryPath"

echo "Script completed at: $(date)"
echo "----------------------------"
