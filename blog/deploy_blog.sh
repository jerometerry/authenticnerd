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

# Pass 1: Hashed Assets (1-Year Immutable Cache)
# Safely targets ONLY the _astro folder where files are guaranteed to have unique hashes.
echo "📦 Uploading immutable hashed assets..."
aws s3 sync dist/_astro/ "s3://${BLOG_BUCKET_NAME}/_astro/" \
  --delete \
  --size-only \
  --cache-control "public, max-age=31536000, immutable"

# Pass 2: Unhashed Assets, HTML, and Data (1-Day Cache)
# Syncs everything else (HTML, favicons, robots.txt) but ignores the _astro folder.
echo "📄 Uploading HTML and unhashed root assets..."
aws s3 sync dist/ "s3://${BLOG_BUCKET_NAME}/" \
  --delete \
  --exclude "_astro/*" \
  --exclude ".DS_Store" \
  --cache-control "no-cache, must-revalidate"

echo "--- 3. INVALIDATING CLOUDFRONT CACHE ---"
aws cloudfront create-invalidation \
    --distribution-id "${BLOG_DISTRIBUTION_ID}" \
    --paths "/index.html" "/posts/*" "/tags/*" "/about/*" "/sitemap-index.xml"

echo "✅ DEPLOYMENT SUCCESSFUL"