# backend/main.py
from fastapi import FastAPI, Body, status, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from typing import List

from .database import get_collection
from .models import LogEntry, LogEntryInDB

app = FastAPI(openapi_prefix="/api")

origins = ["http://localhost:9000", "http://localhost:5173"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

router = APIRouter()
log_collection = get_collection("logs")

@app.post(
    "/log",
    response_model=LogEntryInDB,
    status_code=status.HTTP_201_CREATED,
    operation_id="create_log",
)
async def create_log_endpoint(log: LogEntry = Body(...)):
    """Create a new log entry in the database."""
    log_dict = log.model_dump()
    new_log = await log_collection.insert_one(log_dict)
    created_log = await log_collection.find_one({"_id": new_log.inserted_id})
    return created_log

@app.get("/log", response_model=List[LogEntryInDB], operation_id="list_logs")
async def list_logs_endpoint():
    """Retrieve all log entries from the database."""
    logs = await log_collection.find().to_list(100)
    return logs

app.include_router(router, prefix="/api")