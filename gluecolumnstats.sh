#!/bin/bash
# Function to log both to SSH session and output file
log() {
  echo "$1"
  echo "$1" >> $LOG_FILE
}
 
# File containing database and table details
DB_DETAILS_FILE="dbdetails.txt"
 
# Log file for capturing outputs
LOG_FILE="gluestatlogfile.txt"
 
# Clear the output file
> $LOG_FILE
 
# IAM Role ARN
ROLE_ARN="arn:aws:iam::228873353375:role/cfg-edodataadmin-ec2-us-east-1"
#ROLE_ARN="arn:aws:iam::228873353375:role/AWSGlueServiceRole"
CATALOG_ID="228873353375"
 
log "Starting process at $(date)"
 
# Check if dbdetails.txt exists
if [[ ! -f $DB_DETAILS_FILE ]]; then
    log "Error: File $DB_DETAILS_FILE not found!"
    exit 1
fi
 
# Read the dbdetails.txt file line by line
while IFS=, read -r DATABASE_NAME TABLE_NAME; do
    if [[ -z $DATABASE_NAME || -z $TABLE_NAME ]]; then
        log "Skipping invalid line in file: $DATABASE_NAME, $TABLE_NAME"
        continue
    fi
 
    log "Processing Database: $DATABASE_NAME, Table: $TABLE_NAME"
 
    # Grant SELECT permission
    GRANT_PERMISSION_CMD=$(aws lakeformation grant-permissions \
        --resource "{\"Table\":{\"DatabaseName\":\"$DATABASE_NAME\",\"Name\":\"$TABLE_NAME\"}}" \
        --principal "DataLakePrincipalIdentifier=$ROLE_ARN" \
        --permissions SELECT 2>&1)
 
    if [[ $? -eq 0 ]]; then
        log "Successfully granted SELECT permission for $DATABASE_NAME.$TABLE_NAME"
 
        # Check if column statistics task already exists
# Check if column statistics task already exists
log "Checking if Glue column statistics task already exists for $DATABASE_NAME.$TABLE_NAME"
EXISTING_STATS_CMD=$(aws glue get-column-statistics-task-settings \
        --database-name "$DATABASE_NAME" \
        --table-name "$TABLE_NAME" 2>&1)
        if echo "$EXISTING_STATS_CMD" | grep -q '"Schedule"'; then
        log "Glue column statistics task exists. Updating schedule for $DATABASE_NAME.$TABLE_NAME"
#        log "Checking if Glue column statistics task already exists for $DATABASE_NAME.$TABLE_NAME"
#        CHECK_STATS_CMD=$(aws glue list-column-statistics-task-settings \
#            --database-name "$DATABASE_NAME" \
#            --table-name "$TABLE_NAME" \
#            --catalog-id "$CATALOG_ID" \
#            --query "TaskSettings[?TableName=='$TABLE_NAME'] | length(@)" \
#            --output text 2>&1)
 
#        if [[ $? -eq 0 && $CHECK_STATS_CMD -gt 0 ]]; then
#            log "Glue column statistics task exists. Updating schedule for $DATABASE_NAME.$TABLE_NAME"
 
            UPDATE_STATS_CMD=$(aws glue update-column-statistics-task-settings \
                --database-name "$DATABASE_NAME" \
                --table-name "$TABLE_NAME" \
                --role "$ROLE_ARN" \
                --schedule "cron(15 1 5 * ? *)" \
                --catalog-id "$CATALOG_ID" 2>&1)
 
            if [[ $? -eq 0 ]]; then
                log "Successfully updated Glue column statistics task schedule for $DATABASE_NAME.$TABLE_NAME"
            else
                log "Failed to update Glue column statistics task schedule for $DATABASE_NAME.$TABLE_NAME"
                log "Error: $UPDATE_STATS_CMD"
            fi
        else
            log "Glue column statistics task does not exist. Creating a new task for $DATABASE_NAME.$TABLE_NAME"
 
            CREATE_STATS_CMD=$(aws glue create-column-statistics-task-settings \
                --database-name "$DATABASE_NAME" \
                --table-name "$TABLE_NAME" \
                --role "$ROLE_ARN" \
                --schedule "cron(15 1 5 * ? *)" \
                --catalog-id "$CATALOG_ID" 2>&1)
 
            if [[ $? -eq 0 ]]; then
                log "Successfully created Glue column statistics task for $DATABASE_NAME.$TABLE_NAME"
            else
                log "Failed to create Glue column statistics task for $DATABASE_NAME.$TABLE_NAME"
                log "Error: $CREATE_STATS_CMD"
            fi
        fi
    else
        log "Failed to grant SELECT permission for $DATABASE_NAME.$TABLE_NAME"
        log "Error: $GRANT_PERMISSION_CMD"
    fi
done < "$DB_DETAILS_FILE"
 
log "Process completed at $(date)"
