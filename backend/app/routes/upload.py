from fastapi import APIRouter, UploadFile, File
import os
import uuid

from app.services.ocr import extract_text
from app.services.text_cleaner import clean_text
from app.services.llm_extractor import extract_contract_sla

router = APIRouter()

UPLOAD_DIR = "app/storage/contracts"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/upload-contract")
async def upload_contract(file: UploadFile = File(...)):
    print(f"Received upload request for file: {file.filename}, size: {file.size}")
    # 1. Save uploaded file
    file_id = str(uuid.uuid4())
    file_path = f"{UPLOAD_DIR}/{file_id}_{file.filename}"

    content = await file.read()
    print(f"File content length: {len(content)}")
    with open(file_path, "wb") as f:
        f.write(content)

    print("File saved successfully")

    # 2. OCR
    print("Starting OCR...")
    raw_text = extract_text(file_path)
    print(f"OCR completed, text length: {len(raw_text)}")

    # 3. Clean OCR text
    cleaned_text = clean_text(raw_text)
    print(f"Text cleaned, length: {len(cleaned_text)}")

    # 4. LLM-based SLA extraction
    print("Starting LLM extraction...")
    sla_data = extract_contract_sla(cleaned_text)
    print("LLM extraction completed")

    return {
        "message": "Contract uploaded and processed successfully",
        "contract_id": file_id,
        "filename": file.filename,
        "sla_extracted": sla_data
    }
