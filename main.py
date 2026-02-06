from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
import os
import shutil
from ocr_pipline import extract_text_pipeline
from llm_analysis import analyze_with_llm
from vin import extract_vin
from vin_api import fetch_vehicle_details
from chatbot import contract_chatbot

app = FastAPI()

# Enable CORS for the React frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@app.post("/upload")
async def upload_contract(file: UploadFile = File(...)):
    file_path = os.path.join(UPLOAD_DIR, file.filename)
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    # Run OCR
    text = extract_text_pipeline(file_path)
    
    # Extract VIN
    vin = extract_vin(text)
    
    return {
        "filename": file.filename,
        "text": text,
        "vin": vin
    }

@app.post("/analyze")
async def analyze_contract(data: dict):
    text = data.get("text")
    analysis = analyze_with_llm(text)
    return {"analysis": analysis}

@app.get("/vin/{vin}")
async def get_vin_details(vin: str):
    details = fetch_vehicle_details(vin)
    return details

@app.post("/chat")
async def chat_with_contract(data: dict):
    text = data.get("text")
    query = data.get("query")
    response = contract_chatbot(text, query)
    return {"response": response}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
