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

# 1. UPLOAD EVERYTHING (Default to Long Cache)
# This handles all your images, CSS, and JS.
# We set a 1-year cache because Astro hashes these filenames (e.g., client.CpUatUnr.js).
# If the file changes, the name changes, so it's safe to cache forever.
aws s3 sync blog/dist/ "s3://${BLOG_BUCKET_NAME}" \
  --delete \
  --exclude ".DS_Store" \
  --cache-control "public, max-age=31536000, immutable"

# 2. FIX THE HTML & METADATA (Overwrite with Short Cache)
# We re-upload just the HTML, XML, and TXT files.
# We set max-age=0 to force the browser/CloudFront to check for updates every time.
# This ensures users see your new blog post the second you publish it.
aws s3 cp blog/dist/ "s3://${BLOG_BUCKET_NAME}" \
  --recursive \
  --exclude "*" \
  --include "*.html" \
  --include "*.xml" \
  --include "*.txt" \
  --include "*.json" \
  --exclude ".DS_Store" \
  --cache-control "public, max-age=0, must-revalidate"

aws cloudfront create-invalidation --distribution-id "${BLOG_DISTRIBUTION_ID}" --paths "/*"

echo "--- DEPLOYMENT COMPLETE ---"

echo "Website URL: ${WEBSITE_CLOUDFRONT_URL}"
echo "REST APIGATEWAY URL: ${REST_APIGATEWAY_URL}"
echo "API LAMBDA INVOKE ARN: ${API_LAMBDA_INVOKE_ARN}"
