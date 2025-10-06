#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- 1. Building and Packaging API Lambda ---"
./build_api_lambda.sh

echo "--- 2. Deploying Infrastructure with Terraform ---"
cd terraform

terraform apply --auto-approve

BUCKET_NAME=$(terraform output -raw website_s3_bucket_name)
WEBSITE_DISTRIBUTION_ID=$(terraform output -raw website_cloudformation_distribution)
WEBSITE_CLOUDFRONT_URL=$(terraform output -raw website_cloudfront_url)

API_LAMBDA_INVOKE_ARN=$(terraform output -raw api_lambda_invoke_arn)
REST_APIGATEWAY_URL=$(terraform output -raw rest_apigateway_endpoint_url)

cd ..

echo "--- 3. Configuring Frontend with Live API URL ---"
echo "VITE_API_BASE_URL=${REST_APIGATEWAY_URL}" > frontend/.env.production
echo "Frontend environment configured."

echo "--- 4. Building Frontend ---"
cd frontend
pnpm run build
cd ..

echo "--- 5. Uploading Frontend to S3 ---"
aws s3 sync frontend/dist/ "s3://${BUCKET_NAME}" --delete

echo "--- 6. Invalidating CloudFront Cache ---"
aws cloudfront create-invalidation --distribution-id "${WEBSITE_DISTRIBUTION_ID}" --paths "/*"

echo "--- DEPLOYMENT COMPLETE ---"

echo "Website URL: ${WEBSITE_CLOUDFRONT_URL}"
echo "REST APIGATEWAY URL: ${REST_APIGATEWAY_URL}"
echo "API LAMBDA INVOKE ARN: ${API_LAMBDA_INVOKE_ARN}"
