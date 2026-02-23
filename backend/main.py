# backend/main.py

import time
import asyncio
from datetime import datetime

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from starlette.concurrency import run_in_threadpool
from pydantic import BaseModel
from typing import List
import google.generativeai as genai
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
import os
import tempfile

from backend.config import settings
from backend.models import schemas

app = FastAPI()

import re # Needed for regex

# Configure CORS (ensure your Flutter Web app's origin is allowed dynamically)
# Note: For production, we explicitly allow the Firebase and localhost origins.
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://autofinance-guardian.web.app",
        "https://autofinance-guardian.firebaseapp.com",
        "http://localhost",
        "http://localhost:5000",
        "http://localhost:8080",
    ],
    allow_origin_regex="https?:\/\/localhost(:\d+)?", # Allow all localhost ports
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root_health_check():
    return {"status": "healthy", "service": "AutoFinance Guardian Backend"}

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
            await asyncio.sleep(5) 

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
    
    # Simulate processing time (using non-blocking sleep)
    await asyncio.sleep(5) 

    # MOCK LOGIC: Provide a mock response based on filename or some simple heuristic
    file_name_lower = file.filename.lower()
    if "bad" in file_name_lower or "highrisk" in file_name_lower:
        risk_level = "High"
        hidden_fees = ["Excessive late payment fee (5%)", "Undisclosed administration charges ($150)"]
        penalties = ["Early termination fee = 3 months payments", "High interest rate increase on default"]
        unfair_clauses = ["Lender can unilaterally change terms", "Arbitration clause favors lender"]
        summary = "This contract contains several high-risk clauses, including unilateral term changes and high hidden fees. Proceed with extreme caution and seek legal advice."
    elif "medium" in file_name_lower:
        risk_level = "Medium"
        hidden_fees = ["Minor documentation fee ($25)"]
        penalties = ["Standard late payment fee ($35)"]
        unfair_clauses = []
        summary = "The contract has a few areas for review, but overall appears manageable. Pay attention to documentation fees and standard penalties."
    else:
        risk_level = "Low"
        hidden_fees = []
        penalties = ["Standard late payment fee ($30)"]
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

@app.post("/chat", response_model=schemas.ChatResponse)
async def chat_endpoint(request: schemas.ChatRequest):
    if not settings.GEMINI_API_KEY:
        raise HTTPException(status_code=500, detail="Gemini API key not configured")
    
    try:
        genai.configure(api_key=settings.GEMINI_API_KEY)
        model = genai.GenerativeModel('gemini-1.5-flash')
        
        prompt = f"""
        You are an expert Auto-Finance Guardian AI. 
        Help the user understand auto finance, loans, leases, and contract terms.
        User message: {request.message}
        """
        
        # Run synchronous AI generation in a separate thread to prevent blocking
        response = await run_in_threadpool(model.generate_content, prompt)
        return schemas.ChatResponse(response=response.text)
    except Exception as e:
        print(f"Chat error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

from fastapi.responses import Response

@app.get("/download-analysis")
async def download_analysis(
    risk_level: str = "Low",
    summary: str = "No analysis provided."
):
    """Returns the analysis as a downloadable text file."""
    try:
        report_content = f"CONTRACT ANALYSIS REPORT\n"
        report_content += f"Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
        report_content += f"---------------------------------\n"
        report_content += f"RISK LEVEL: {risk_level.upper()}\n\n"
        report_content += f"SUMMARY:\n{summary}\n\n"
        report_content += f"---------------------------------\n"
        report_content += "End of Report\n"

        return Response(
            content=report_content,
            media_type="text/plain",
            headers={
                "Content-Disposition": f"attachment; filename=Contract_Analysis_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
            }
        )
    except Exception as e:
        print(f"Download error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# --- Your existing FastAPI routes and application logic would follow here ---
# Example:
# @app.get("/")
# async def read_root():
#     return {"message": "Hello from FastAPI backend!"}
