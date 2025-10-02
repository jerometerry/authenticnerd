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
rm -rf build backend.zip
mkdir -p build/
pip install -r backend/requirements.txt -t build/
cp backend/*.py build/
cd build
zip -r ../backend.zip .
cd ..
```

### Deploy
```baqsh
cd terraform
terraform apply --auto-approve
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