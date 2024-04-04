#!/opt/app-root/bin/python3

from dotenv import load_dotenv

load_dotenv()

import logging
import os
import uvicorn
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from app.api.routers.chat import chat_router
from app.settings import init_settings

init_settings()

app = FastAPI()
api = FastAPI(root_path="/api")
api.include_router(chat_router, prefix="/chat")
app.mount("/api", api)
app.mount("/", StaticFiles(directory="front", html=True), name="static")

environment = os.getenv("ENVIRONMENT", "dev")  # Default to 'development' if not set

if environment == "dev":
    logger = logging.getLogger("uvicorn")
    logger.warning("Running in development mode - allowing CORS for all origins")
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

if __name__ == "__main__":
    app_host = os.getenv("APP_HOST", "0.0.0.0")
    app_port = int(os.getenv("APP_PORT", "8080"))
    reload = True if environment == "dev" else False

    uvicorn.run(app="main:app", host=app_host, port=app_port, reload=reload)
