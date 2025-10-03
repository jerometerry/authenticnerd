# backend/config.py
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env")
    MONGO_URI: str = "mongodb://localhost:27017"
    DATABASE_NAME: str = "personalsystem"

settings = Settings()
