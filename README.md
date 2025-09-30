# My Personal System

This project contains a modern full-stack application with a React frontend and a FastAPI backend, designed for personal organization and data analysis.

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
---

## Accessing the App & API Docs

### Frontend Application
When you run `pnpm start`, the Vite server will print the local URL to the console. It is typically:
* **`http://localhost:5173`**

### Backend API Docs
FastAPI automatically generates interactive API documentation. While the backend server is running, you can access them at:
* **Swagger UI**: `http://127.0.0.1:8000/docs` 
* **ReDoc**: `http://127.0.0.1:8000/redoc`