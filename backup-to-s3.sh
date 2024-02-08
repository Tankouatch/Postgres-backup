#!/bin/bash

# Set the date format, filename and the S3 bucket path
BACKUP_DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILENAME="backup_$BACKUP_DATE.sql.tar.gz"
S3_BUCKET_PATH="s3://del-db-backup/S6/s4tankoua/$BACKUP_FILENAME"
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_USER=$DB_USER
DB_NAME=$DB_NAME
# Create a dump of all databases into a single file
## pg_dumpall -U $POSTGRES_USER > /backups/$BACKUP_FILENAME
export PGPASSWORD=$DB_PASSWORD 
pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER > /backups/$BACKUP_FILENAME

# Check if pg_dump was successful
if [ $? -eq 0 ]; then
    echo "Database backup was successful."
else
    echo "Database backup failed."
    exit 1
fi
# Upload the backup to the S3 bucket
aws s3 cp /backups/$BACKUP_FILENAME $S3_BUCKET_PATH
# Check if the backup status
if [ $? -eq 0 ]; then
    echo "Backup $BACKUP_FILENAME uploaded to S3."
else
    echo "Backup failed"
    exit 1
fi

#Removing old backup
find /backups -type f -name "*.sql.tar.gr" -mtime +30 -exec rm {} \;
echo "Old backups cleaned up."