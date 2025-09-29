# backend/database.py
from pymongo.mongo_client import MongoClient
from .config import settings

client = MongoClient(settings.MONGO_URI)
db = client[settings.DATABASE_NAME]

def get_collection(name: str):
    return db.get_collection(name)