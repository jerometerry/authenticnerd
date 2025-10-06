#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- 1. Building and Packaging API Lambda ---"
./build_api_lambda.sh

echo "--- 2. Deploying Infrastructure with Terraform ---"
cd terraform

terraform apply --auto-approve

WEBSITE_BUCKET_NAME=$(terraform output -raw website_s3_bucket_name)
WEBSITE_DISTRIBUTION_ID=$(terraform output -raw website_cloudformation_distribution)
WEBSITE_CLOUDFRONT_URL=$(terraform output -raw website_cloudfront_url)

API_LAMBDA_INVOKE_ARN=$(terraform output -raw api_lambda_invoke_arn)
REST_APIGATEWAY_URL=$(terraform output -raw rest_apigateway_endpoint_url)

BLOG_BUCKET_NAME=$(terraform output -raw blog_s3_bucket_name)
BLOG_DISTRIBUTION_ID=$(terraform output -raw blog_cloudfront_distribution_id)

cd ..

echo "--- 3. Configuring and Deploying Main Website ---"
echo "VITE_API_BASE_URL=${REST_APIGATEWAY_URL}" > frontend/.env.production
cd frontend && pnpm run build && cd ..
aws s3 sync frontend/dist/ "s3://${WEBSITE_BUCKET_NAME}" --delete
aws cloudfront create-invalidation --distribution-id "${WEBSITE_DISTRIBUTION_ID}" --paths "/*"
echo "Frontend environment configured."

echo "--- 4. Building and Deploying Blog ---"
cd blog && pnpm run build && cd ..
aws s3 sync blog/dist/ "s3://${BLOG_BUCKET_NAME}" --delete
aws cloudfront create-invalidation --distribution-id "${BLOG_DISTRIBUTION_ID}" --paths "/*"

echo "--- DEPLOYMENT COMPLETE ---"

echo "Website URL: ${WEBSITE_CLOUDFRONT_URL}"
echo "REST APIGATEWAY URL: ${REST_APIGATEWAY_URL}"
echo "API LAMBDA INVOKE ARN: ${API_LAMBDA_INVOKE_ARN}"
