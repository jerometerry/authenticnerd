# backend/database.py
from pymongo import AsyncMongoClient
from .config import settings

client = AsyncMongoClient(settings.MONGO_URI)
db = client[settings.DATABASE_NAME]

def get_collection(name: str):
    return db.get_collection(name)
