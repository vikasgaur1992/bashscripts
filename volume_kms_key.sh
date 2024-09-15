#Bash script to get KMS key attached to volumes attached to AWS EC2 instance 
INSTANCE_IDS=("abc" "i-abc") # Replace with your actual instance IDs

for INSTANCE_ID in "${INSTANCE_IDS[@]}"; do
  echo "Processing instance: $INSTANCE_ID"
  
  # Get all volume IDs attached to the instance
  VOLUME_IDS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[].Instances[].BlockDeviceMappings[].Ebs.VolumeId" --output text)
  
  # Loop through the volume IDs and fetch the KMS key for each
  for VOLUME_ID in $VOLUME_IDS; do
    echo "  Volume ID: $VOLUME_ID"
    aws ec2 describe-volumes --volume-ids $VOLUME_ID --query "Volumes[].{VolumeId:VolumeId,KmsKeyId:KmsKeyId}" --output table
  done
  
  echo "-------------------------------------------------"
done
