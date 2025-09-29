from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# --- CORS Middleware ---
# This is crucial for allowing your frontend to talk to your backend
origins = [
    "http://localhost:9000", # Default Aurelia dev server port
    "http://localhost:5173", # Default Vite dev server port
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"Hello": "From the FastAPI Backend"}
