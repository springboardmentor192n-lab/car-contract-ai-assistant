# backend/main.py

import time
import asyncio
from datetime import datetime

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List

# --- Existing imports would be here ---
# from backend.database import engine, Base
# Base.metadata.create_all(bind=engine) # Example if you have a database setup

app = FastAPI()

import re # Needed for regex

# Configure CORS (ensure your Flutter Web app's origin is allowed dynamically)
# Regular expression to allow any port on localhost or 127.0.0.1
# This pattern matches:
# - http://localhost:PORT
# - http://127.0.0.1:PORT
# where PORT is any sequence of digits.
# Note: For production, this should be narrowed down to specific trusted origins.
frontend_origins_regex = r"https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?"

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=frontend_origins_regex, # Use regex for dynamic localhost ports
    allow_credentials=True,
    allow_methods=["*"], # Allows POST, GET, OPTIONS (and others)
    allow_headers=["*"], # Allows all headers including Content-Type for multipart
)

# --- WebSocket endpoint for real-time activity ---
@app.websocket("/ws/activity")
async def websocket_activity_endpoint(websocket: WebSocket):
    await websocket.accept()
    print("Client connected to /ws/activity")
    try:
        # Initial mock message
        await websocket.send_json({"id": "init_mock", "title": "Backend active", "type": "backend_status", "status": "Connected", "timestamp": str(datetime.now())})

        # Keep the connection alive, sending mock updates
        while True:
            # You would typically send real-time activity updates here from your backend logic
            # For this mock, we're just simulating some backend presence.
            await asyncio.sleep(5) # Send a message every 5 seconds to keep connection alive
            # If you want to simulate activity stream, integrate your actual activity generation here.
            # Example:
            # await websocket.send_json({"id": str(uuid.uuid4()), "title": "New activity", "type": "some_type", "status": "processing", "timestamp": str(datetime.now())})

    except WebSocketDisconnect:
        print("Client disconnected from /ws/activity")
    except Exception as e:
        print(f"WebSocket error in /ws/activity: {e}")
    finally:
        await websocket.close()


# --- Pydantic model for Contract Analysis API response ---
class ContractAnalysisResponse(BaseModel):
    file_name: str
    risk_level: str
    hidden_fees: List[str]
    penalties: List[str]
    unfair_clauses: List[str]
    summary: str

# --- POST /analyze_contract endpoint ---
@app.post("/analyze_contract", response_model=ContractAnalysisResponse)
async def analyze_contract_endpoint(file: UploadFile = File(...)):
    # Simulate AI analysis
    file_content = await file.read() # Read the file content
    print(f"Received file: {file.filename}, size: {len(file_content)} bytes for analysis.")
    
    # Simulate processing time
    time.sleep(2)

    # MOCK LOGIC: Provide a mock response based on filename or some simple heuristic
    file_name_lower = file.filename.lower()
    if "bad" in file_name_lower or "highrisk" in file_name_lower:
        risk_level = "High"
        hidden_fees = ["Excessive late payment fee (5%)", "Undisclosed administration charges (\$150)"]
        penalties = ["Early termination fee = 3 months payments", "High interest rate increase on default"]
        unfair_clauses = ["Lender can unilaterally change terms", "Arbitration clause favors lender"]
        summary = "This contract contains several high-risk clauses, including unilateral term changes and high hidden fees. Proceed with extreme caution and seek legal advice."
    elif "medium" in file_name_lower:
        risk_level = "Medium"
        hidden_fees = ["Minor documentation fee (\$25)"]
        penalties = ["Standard late payment fee (\$35)"]
        unfair_clauses = []
        summary = "The contract has a few areas for review, but overall appears manageable. Pay attention to documentation fees and standard penalties."
    else:
        risk_level = "Low"
        hidden_fees = []
        penalties = ["Standard late payment fee (\$30)"]
        unfair_clauses = []
        summary = "This contract appears to have fair and standard terms. The only penalty noted is for late payments, which is common. This is a low-risk agreement."
    
    return ContractAnalysisResponse(
        file_name=file.filename,
        risk_level=risk_level,
        hidden_fees=hidden_fees,
        penalties=penalties,
        unfair_clauses=unfair_clauses,
        summary=summary
    )

# --- Your existing FastAPI routes and application logic would follow here ---
# Example:
# @app.get("/")
# async def read_root():
#     return {"message": "Hello from FastAPI backend!"}
