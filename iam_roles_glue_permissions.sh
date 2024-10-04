#!/bin/bash

# Define the output CSV file
output_file="iam_roles_glue_permissions.csv"

# Write CSV headers
echo "RoleName,PolicyArn,HasGlueCreateJobPermission,HasFullGluePermission" > $output_file

# Loop through all IAM roles
for role in $(aws iam list-roles --query 'Roles[*].RoleName' --output text --region us-east-1); do
  echo "Checking Role: $role"

  # Check managed policies attached to each role
  for policy in $(aws iam list-attached-role-policies --role-name "$role" --query 'AttachedPolicies[*].PolicyArn' --output text --region us-east-1); do
    # Get the default policy version
    policy_version=$(aws iam get-policy --policy-arn "$policy" --query 'Policy.DefaultVersionId' --output text --region us-east-1)
    
    # Fetch the default policy version and check for 'glue:CreateJob' and 'glue:*' (full Glue permission)
    policy_document=$(aws iam get-policy-version --policy-arn "$policy" --version-id "$policy_version" --query 'PolicyVersion.Document.Statement' --region us-east-1)

    # Check if the policy grants glue:CreateJob
    has_create_job=$(echo "$policy_document" | grep -q 'glue:CreateJob' && echo true || echo false)

    # Check if the policy grants full glue permission (glue:*)
    has_full_glue=$(echo "$policy_document" | grep -q 'glue:*' && echo true || echo false)

    # Add a line to the CSV file with the results
    echo "$role,$policy,$has_create_job,$has_full_glue" >> $output_file
  done
done

echo "Data has been written to $output_file"
