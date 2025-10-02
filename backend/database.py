# backend/database.py
from pymongo import AsyncMongoClient
from .config import settings
from .main import get_mongo_uri

client = AsyncMongoClient(get_mongo_uri())
db = client[settings.DATABASE_NAME]

def get_collection(name: str):
    return db.get_collection(name)
