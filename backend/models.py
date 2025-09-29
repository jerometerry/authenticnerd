# backend/models.py
from pydantic import BaseModel, Field
from bson import ObjectId
from typing import Optional

# This is a helper class to handle MongoDB's ObjectId
class PyObjectId(ObjectId):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate
    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid ObjectId")
        return ObjectId(v)
    @classmethod
    def __get_pydantic_json_schema__(cls, field_schema):
        field_schema.update(type="string")

# Model for data you receive from the user (e.g., in a POST request)
class LogEntry(BaseModel):
    content: str = Field(...)
    mood: int = Field(..., ge=1, le=5) # Example: mood rating 1-5

    class Config:
        json_schema_extra = {
            "example": {
                "content": "Worked on the new personal system project.",
                "mood": 5,
            }
        }

# Model for data you send back to the user (includes the DB-generated ID)
class LogEntryInDB(LogEntry):
    id: Optional[PyObjectId] = Field(alias="_id")
