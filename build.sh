#!/bin/bash
# Stop on any error
set -e

echo "--- Building Lambda Package ---"

# Define directories
BACKEND_DIR="backend"
BUILD_DIR="${BACKEND_DIR}/build"
APP_DIR="${BUILD_DIR}/app" # New directory for our app code
ZIP_FILE_NAME="backend.zip"
REQUIREMENTS_FILE="requirements.txt"

# 1. Clean up old build files
rm -rf "${BUILD_DIR}" "${ZIP_FILE_NAME}"
echo "Cleaned up old build files."

# 2. Use Docker to install dependencies into the build directory
echo "Installing dependencies for Linux..."
docker run --platform linux/amd64 --rm --entrypoint "" -v "$(pwd)/${BACKEND_DIR}":/var/task public.ecr.aws/lambda/python:3.12 /bin/sh -c "pip install -r ${REQUIREMENTS_FILE} -t build/"

# 3. Create the 'app' package structure
echo "Creating 'app' package..."
mkdir "${APP_DIR}"
touch "${APP_DIR}/__init__.py" # Makes it a Python package

# 4. Copy your application source code into the 'app' directory
echo "Copying application code..."
cp "${BACKEND_DIR}"/*.py "${APP_DIR}/"

# 5. Create the final zip file from the contents of the build directory
echo "Creating zip package..."
cd "${BUILD_DIR}"
zip -r "../../${ZIP_FILE_NAME}" .
cd ../.. # Return to the project root

echo "--- Lambda package created successfully at ${ZIP_FILE_NAME} ---"