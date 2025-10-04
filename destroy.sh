#!/bin/bash
# This script safely tears down all project infrastructure.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- 1. Getting S3 Bucket Name from Terraform Output ---"
# Navigate to the terraform directory to get the output
cd terraform
BUCKET_NAME=$(terraform output -raw website_s3_bucket_name)
cd .. # Return to project root

if [ -z "$BUCKET_NAME" ]; then
    echo "Could not retrieve S3 bucket name. Exiting."
    exit 1
fi

echo "S3 Bucket to empty: ${BUCKET_NAME}"

echo "--- 2. Emptying S3 Bucket ---"
# The --force flag is needed to delete objects without prompting
aws s3 rm "s3://${BUCKET_NAME}" --recursive

echo "S3 bucket emptied successfully."

echo "--- 3. Destroying Infrastructure with Terraform ---"
cd terraform
terraform destroy --auto-approve
cd .. # Return to project root

echo "--- TEARDOWN COMPLETE ---"