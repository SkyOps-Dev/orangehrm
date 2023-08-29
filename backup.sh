#!/bin/bash

# Define the backup directory on the host machine
BACKUP_DIR="/var/lib/docker/volumes"

# MySQL container name
MYSQL_CONTAINER="orange-mysql"

# MySQL database details
DB_USER="orange1"
DB_PASSWORD="orange1"
DB_NAME="orange1"

# S3 bucket name
S3_BUCKET="orangehrm-backup"

# Timestamp for the backup filename
TIMESTAMP=$(date "+%Y-%m-%d-%H-%M-%S")

# Filename for the backup file
BACKUP_FILENAME="${DB_NAME}_backup_${TIMESTAMP}.sql"

# Grant PROCESS privilege to the user
docker exec -i ${MYSQL_CONTAINER} mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT PROCESS ON *.* TO 'orange1'@'%'"

# Run the mysqldump command inside the MySQL container
docker exec -i ${MYSQL_CONTAINER} mysqldump -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} > "${BACKUP_DIR}/${BACKUP_FILENAME}"

# Check if the backup was successful
if [ $? -eq 0 ]; then
  echo "Database backup completed successfully. Backup file: ${BACKUP_DIR}/${BACKUP_FILENAME}"
   # Upload the backup file to S3
  aws s3 cp "${BACKUP_DIR}/${BACKUP_FILENAME}" "s3://${S3_BUCKET}/${BACKUP_FILENAME}"
  
  if [ $? -eq 0 ]; then
    echo "Backup file uploaded to S3: s3://${S3_BUCKET}/${BACKUP_FILENAME}"
  else
    echo "Failed to upload backup file to S3."
  fi
else
  echo "Database backup failed."
fi
# Schedule the script to run again using cron job
(crontab -l ; echo "0 18 * * 1-5 /bin/bash ./backup.sh") | crontab -
