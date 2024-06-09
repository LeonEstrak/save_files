directoryPath="/home/aniket/ludusavi-backup"

ludusavi backup --no-cloud-sync --force --path "$directoryPath"

$directoryPath/backup.sh "$directoryPath"

echo "Script completed at: $(date)"
echo "----------------------------"
