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

Based on the resources deployed, estimated monthly cost will be around **$92 USD** with a NAT Gateway setup, or around **$75 USD** by switching to the more cost-effective VPC Endpoint setup.

Here’s a framework for how those costs break down.

### ## Cost Analysis Framework 💰

Costs can be broken down into two main categories: fixed recurring costs (which form a monthly baseline) and usage-based costs (which for a personal project, will likely be free).

#### ### 1. Fixed Monthly Costs (Your Baseline)
These are resources that are charged for every hour they exist, regardless of traffic. This is where the vast majority of the AWS bill will come from.
*(Calculations use an average of 730 hours per month)*

* **MongoDB Atlas M10 Cluster**: **~$58.40 / month**
    * M10 Cluster `$0.08/hour`, this dedicated cluster is the largest single expense.

* **Networking (Main AWS Cost)**: Key decision point.
    * **Option A: NAT Gateway (Current Setup)**: **~$32.85 / month**
        * The NAT Gateway itself has a fixed hourly cost (`$0.045/hr * 730 hours`).
        * There's also a small data processing fee (`$0.045/GB`), which will be negligible for current use.
    * **Option B: VPC Endpoints (Recommended)**: **~$14.60 / month**
        * Each VPC Interface Endpoint has a fixed hourly cost (`~$0.01/hr`). Project has two (SSM and KMS).
        * `$0.01/hr * 2 endpoints * 730 hours = $14.60`.
        * This option is **over 50% cheaper** for projects networking costs.

* **AWS KMS Key**: **$1.00 / month**
    * Flat fee for each custom KMS key created.

#### ### 2. Usage-Based Costs (Likely Free)
These services have generous "Always Free" tiers. For a personal project, usage will almost certainly fall within these free limits every month.

* **AWS Lambda**: **Effectively $0**. The free tier includes 1 million requests per month.
* **API Gateway (HTTP API)**: **Effectively $0**. The free tier includes 1 million requests per month for the first 12 months, and is extremely cheap after that.
* **S3 & CloudFront**: **Effectively $0**. React app is tiny, and the free tiers for storage (S3) and data transfer (CloudFront) are enormous.

#### ### 3. No-Cost Resources
Many of the project resources created don't have a direct cost. They are the "glue" that holds the architecture together.
* **IAM** (Roles, Policies)
* **VPC** (The VPC itself, Subnets, Route Tables, Security Groups)
* **SSM Parameter Store** (The standard parameter itself is free)

---
### ## Summary and Recommendation 📊

Here is the side-by-side comparison of two main architectural choices:

| Service | Monthly Cost (NAT Gateway) | Monthly Cost (VPC Endpoints) |
| :--- | :--- | :--- |
| MongoDB Atlas M10 | ~$58.40 | ~$58.40 |
| **Networking** | **~$32.85** | **~$14.60** |
| AWS KMS Key | $1.00 | $1.00 |
| Usage-Based Services | ~$0.00 | ~$0.00 |
| **Total Estimated Bill** | **~$92.25 USD** | **~$74.00 USD** |

**Recommendation**: Now that your system is stable, I recommend you **revert to the VPC Endpoint setup**. It will provide the same level of security and functionality while saving you approximately $18 per month.
