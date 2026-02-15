#!/bin/bash
set -e

if [ -z "$BLOG_BUCKET_NAME" ] || [ -z "$BLOG_DISTRIBUTION_ID" ]; then
  echo "❌ Error: Missing configuration."
  echo "Ensure BLOG_BUCKET_NAME and BLOG_DISTRIBUTION_ID are set in blog/.env"
  exit 1
fi

echo "--- 1. BUILDING ASTRO SITE ---"
pnpm install
pnpm run build

echo "--- 2. DEPLOYING TO S3 (Two-Pass Sync) ---"

# Pass 1: Assets (Long Cache)
echo "📦 Uploading immutable assets..."
aws s3 sync dist/ "s3://${BLOG_BUCKET_NAME}" \
  --delete \
  --exclude ".DS_Store" \
  --exclude "*.html" \
  --exclude "*.xml" \
  --exclude "*.json" \
  --cache-control "public, max-age=31536000, immutable"

# Pass 2: HTML/Data (Short Cache)
echo "📄 Uploading HTML and data..."
aws s3 cp dist/ "s3://${BLOG_BUCKET_NAME}" \
  --recursive \
  --exclude "*" \
  --include "*.html" \
  --include "*.xml" \
  --include "*.txt" \
  --include "*.json" \
  --cache-control "public, max-age=0, must-revalidate"

echo "--- 3. INVALIDATING CLOUDFRONT CACHE ---"
aws cloudfront create-invalidation \
    --distribution-id "${BLOG_DISTRIBUTION_ID}" \
    --paths "/*"

echo "✅ DEPLOYMENT SUCCESSFUL"