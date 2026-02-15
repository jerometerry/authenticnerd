#!/bin/bash
set -e

if [ ! -f ./.env ]; then
    echo "❌ Error: ./.env file not found."
    echo "👉 Please copy ./.env.example to blog/.env and fill in your values."
    exit 1
fi

echo "Loading configuration from ./.env..."
set -a
source ./.env
set +a

echo "🚀 Starting deployment for bucket: ${BLOG_BUCKET_NAME}"
./deploy_blog.sh