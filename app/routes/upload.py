#contract upload logic file 
from fastapi import APIRouter, UploadFile, File
import os
import uuid

router = APIRouter()

UPLOAD_DIR = "app/storage/contracts"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/upload-contract")
async def upload_contract(file: UploadFile = File(...)):
    file_id = str(uuid.uuid4())
    file_path = f"{UPLOAD_DIR}/{file_id}_{file.filename}"

    with open(file_path, "wb") as f:
        f.write(await file.read())

    return {
        "message": "Contract uploaded successfully",
        "contract_id": file_id,
        "filename": file.filename
    }
