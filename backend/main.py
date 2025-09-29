# backend/main.py
from fastapi import FastAPI, Body, status
from fastapi.middleware.cors import CORSMiddleware
from typing import List

from .database import get_collection
from .models import LogEntry, LogEntryInDB

app = FastAPI()

origins = ["http://localhost:9000", "http://localhost:5173"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

log_collection = get_collection("logs")

@app.post("/logs/", response_model=LogEntryInDB, status_code=status.HTTP_201_CREATED)
async def create_log(log: LogEntry = Body(...)):
    """Create a new log entry in the database."""
    log_dict = log.model_dump()
    new_log = await log_collection.insert_one(log_dict)
    created_log = await log_collection.find_one({"_id": new_log.inserted_id})
    return created_log

@app.get("/logs/", response_model=List[LogEntryInDB])
async def list_logs():
    """Retrieve all log entries from the database."""
    # The async cursor from PyMongo has a .to_list() method, just like Motor
    logs = await log_collection.find().to_list(100)
    return logs