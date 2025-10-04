# My Personal System

This project contains a modern full-stack application with a React frontend and a FastAPI backend, designed for personal organization and data analysis.

## Problem Statement

The primary motivation for this project is to replace a manual, spreadsheet-based system for tracking daily activities. This data is used to analyze patterns and guide decisions aimed at improving quality of life. While functional, the spreadsheet approach is time-consuming, error-prone, and difficult to query for meaningful insights.

This application solves these problems by providing a dedicated, web-based interface for streamlined data entry and a structured database for powerful querying and future analysis.

## Project Goals

This project aims to create a superior workflow for personal data tracking with the following goals:

* **Streamlined Data Entry**: Provide a simple, fast, and mobile-friendly interface for logging daily activities. This replaces the cumbersome, time-consuming, and error-prone process of manually editing spreadsheets.

* **Centralized Data Store**: Consolidate all personal data into a single, secure MongoDB database, creating a reliable "single source of truth."

* **Powerful Analytics**: Enable robust querying and analysis of the collected data to identify patterns and insights that can be used to guide decisions and improve quality of life.

* **Flexible Data Export**: Retain the benefits of spreadsheet analysis by providing the ability to generate and export custom spreadsheets from the central data store on demand.

## Technology Stack

* **Backend**: Python, FastAPI, Pydantic, PyMongo (Async Driver), Uvicorn
* **Frontend**: TypeScript, React, Vite, Redux Toolkit (RTK Query), PNPM
* **Database**: MongoDB
* **Infrastructure**: Docker

---

## Development Workflow

### Initial One-Time Setup

1.  **Backend Dependencies (from the project root):**
    ```bash
    cd backend
    python -m venv .venv
    source .venv/bin/activate
    pip install "fastapi[all]" "pymongo[async]"
    # It's also a good idea to create a requirements.txt file
    # pip freeze > requirements.txt
    ```

2.  **Frontend Dependencies (from the `frontend` directory):**
    ```bash
    cd frontend
    pnpm install
    ```
3. **Configure Terraform**
	```bash
	brew install tfenv
	tfenv install latest
	tfenv use latest
	```

### Running the Application

You will need **three separate terminal windows** open.

#### Terminal 1: Run MongoDB
**First time only:**
```bash
docker run --name my-mongo -p 27017:27017 -d mongo
```

**To start the container on subsequent runs:**
```bash
docker start my-mongo
```
> **Tip:** To stop the container, run `docker stop my-mongo`.

#### Terminal 2: Start the Backend API
From the **project root** (`my-personal-system`):
```bash
source backend/.venv/bin/activate
uvicorn backend.main:app --reload
```

#### Terminal 3: Start the Frontend App
From the **`frontend`** directory:
```bash
pnpm start
```

### Code Generation
To update the RTK Query hooks after making changes to the backend API:

1.  Make sure the backend API is running.
2.  From the **`frontend`** directory, run:
    ```bash
    pnpm run codegen
    ```

### Build
```bash
./build.sh
```

### Deploy
```baqsh
cd terraform
terraform apply --auto-approve
cd ..
cd frontend
pnpm run build
aws s3 sync ./dist s3://<your-bucket-name>

aws cloudfront create-invalidation --distribution-id <your-distribution-id> --paths "/*"
```

---

### Additional Scripts

**Nuke MongoDB**
⚠️ **Warning:** This will permanently delete all data in the container.
```bash
docker stop my-mongo
docker rm my-mongo
docker run --name my-mongo -p 27017:27017 -d mongo
```

**Hard Restart API Server
```bash
# CTRL+C to stop the running server
uvicorn backend.main:app --reload
```

## Accessing the App & API Docs

### Frontend Application
When you run `pnpm start`, the Vite server will print the local URL to the console. It is typically:
* **`http://localhost:5173`**

### Backend API Docs
FastAPI automatically generates interactive API documentation. While the backend server is running, you can access them at:
* **Swagger UI**: `http://127.0.0.1:8000/docs` 
* **ReDoc**: `http://127.0.0.1:8000/redoc`

## AWS Setup

MongoDB Atlas Connection needs to be set in SSM Parameter Store. 
Parameter Name: /MyPersonalSystem/MongoUri

Terraform deployment requires `PowerUserAccess` policy along with the following IAM permissions


```json
{
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"iam:GetRole",
				"iam:CreateRole",
				"iam:DeleteRole",
				"iam:AttachRolePolicy",
				"iam:DetachRolePolicy",
				"iam:PassRole",
				"iam:PutRolePolicy",
				"iam:ListRolePolicies",
				"iam:ListAttachedRolePolicies",
				"iam:ListInstanceProfilesForRole",
				"iam:TagRole"
			],
			"Resource": "arn:aws:iam::<ACCOUNT_ID>:role/lambda-exec-role"
		},
		{
			"Effect": "Allow",
			"Action": [
				"iam:GetPolicy",
				"iam:CreatePolicy",
				"iam:DeletePolicy",
				"iam:GetPolicyVersion",
				"iam:ListPolicyVersions",
				"iam:TagPolicy"
			],
			"Resource": "arn:aws:iam::<ACCOUNT_ID>:policy/lambda-policy"
		}
	]
}
```

## AWS Cost Analysis

Of course. Here is a version of the cost analysis rewritten to be a neutral description for your `README.md` file.

---
## Estimated Monthly Cost

The estimated monthly cost to run this project on AWS with the current serverless architecture (using VPC Endpoints) is approximately **$74 USD**.

The project's costs can be broken down into two main categories: fixed recurring costs, which form the monthly baseline, and usage-based costs, which are expected to be free for this project's low-traffic use case.

*(Calculations use an average of 730 hours per month)*

### 1. Fixed Monthly Costs (The Baseline)
The majority of the cost comes from fixed, hourly charges for the dedicated infrastructure required for this secure, production-ready setup.

* **MongoDB Atlas M10 Cluster**: **~$58.40 / month**
    * (`$0.08/hour * 730 hours`) A dedicated cluster is required to support the secure VPC Peering connection.

* **AWS VPC Endpoints**: **~$14.60 / month**
    * (`$0.01/hour * 2 endpoints * 730 hours`) These provide a secure, private network path from the Lambda function to AWS services (SSM and KMS), avoiding the need for a more expensive NAT Gateway.

* **AWS KMS Key**: **$1.00 / month**
    * This is the flat fee for the custom key used to encrypt the database credentials.

### 2. Usage-Based Costs (Effectively Free)
The following services are usage-based, but their costs are expected to be **$0** as the project's traffic falls well within the AWS Free Tier.

* **AWS Lambda**: 1 million free requests/month.
* **API Gateway (HTTP API)**: 1 million free requests/month (first 12 months).
* **S3 & CloudFront**: Generous free tiers for storage and data transfer.

### Summary

| Service | Estimated Monthly Cost |
| :--- | :--- |
| MongoDB Atlas M10 | ~$58.40 |
| AWS Networking (VPC Endpoints) | ~$14.60 |
| AWS KMS Key | $1.00 |
| Usage-Based Services | ~$0.00 |
| **Total Estimated Bill** | **~$74.00 USD** |