#!/bin/bash
# Load DB credentials from secrets.yaml
DB_HOST=$(yq e '.DB_HOST' configMap.yaml)
DB_PORT=$(yq e '.DB_PORT' secret.yaml)
DB_USER=$(yq e '.DB_USER' configMap.yaml)
DB_NAME=$(yq e '.DB_NAME' configMap.yaml)
DB_PASSWORD=$(yq e '.DB_PASSWORD' secret.yaml)
AWS_ACCESS_KEY_ID=$(yq e '.AWS_ACCESS_KEY_ID' secret.yaml)
AWS_SECRET_ACCESS_KEY=$(yq e '.AWS_SECRET_ACCESS_KEY' secret.yaml)
AWS_DEFAULT_REGION=$(yq e '.AWS_DEFAULT_REGION' secret.yaml)
# Set the date format, filename and the S3 bucket path
BACKUP_DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILENAME="backup_$BACKUP_DATE.sql.tar.gz"
S3_BUCKET_PATH="s3://del-db-backup/S6/s4tankoua/$BACKUP_FILENAME"

# Create a dump of the database and compress it
if [[ -z "$DB_PORT" || "$DB_NAME" || "$DB_HOST" || "$DB_USER" || "$DB_PASSWORD" == "null" ]]; then
    echo "Error: DB_PORT is not set or has an invalid value."
    exit 1
fi

export PGPASSWORD="$DB_PASSWORD"
pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" | gzip > "/backups/$BACKUP_FILENAME"

# Check if pg_dump was successful
if [ $? -eq 0 ]; then
    echo "Database backup was successful."
else
    echo "Database backup failed."
    exit 1
fi

# Upload the backup to the S3 bucket
aws s3 cp "/backups/$BACKUP_FILENAME" $S3_BUCKET_PATH

# Check if the backup status
if [ $? -eq 0 ]; then
    echo "Backup $BACKUP_FILENAME uploaded to S3."
else
    echo "Backup failed"
    exit 1
fi

# Removing old backups
find /backups -type f -name "*.sql.tar.gz" -mtime +30 -exec rm {} \;
echo "Old backups cleaned up."
