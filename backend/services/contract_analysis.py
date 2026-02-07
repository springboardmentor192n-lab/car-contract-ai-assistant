from fastapi import HTTPException
import pytesseract
from PIL import Image
from pdf2image import convert_from_path
from pdf2image.exceptions import PDFPageCountError, PDFInfoNotInstalledError
from typing import Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
import uuid
import os

from backend.utils.helpers import extract_financial_terms, analyze_text_for_risks, calculate_risk_score_and_level
from backend.models import schemas
from backend import crud

async def analyze_contract_service(db: AsyncSession, contract_id: uuid.UUID):
    # This is a placeholder for actual analysis logic
    # In a real application, you'd fetch the contract file, perform OCR,
    # and then apply AI analysis.
    
    # 1. Fetch contract details
    contract = await crud.get_contract(db, contract_id)
    if not contract:
        raise HTTPException(status_code=404, detail="Contract not found for analysis.")
    
    file_path = contract.file_path
    
    if not file_path or not os.path.exists(file_path):
        await crud.update_contract(
            db, contract_id, schemas.ContractUpdate(analysis_status="FAILED", upload_status="FAILED")
        )
        raise HTTPException(status_code=400, detail="Contract file not found.")

    extracted_text = ""
    # Assuming content type based on file extension for simplicity
    content_type = "application/pdf" # Default for this example

    try:
        if content_type == "application/pdf":
            try:
                # This requires poppler-utils to be installed
                pages = convert_from_path(file_path)
                for page in pages:
                    extracted_text += pytesseract.image_to_string(page) + "\n"
            except (PDFPageCountError, PDFInfoNotInstalledError) as e:
                # Update contract status to failed
                await crud.update_contract(
                    db, contract_id, schemas.ContractUpdate(analysis_status="FAILED", upload_status="FAILED")
                )
                raise HTTPException(
                    status_code=400,
                    detail=f"PDF processing failed: {e}. Ensure poppler-utils is installed and in PATH."
                )
        else:
            # Handle other types if necessary, or raise error
            await crud.update_contract(
                db, contract_id, schemas.ContractUpdate(analysis_status="FAILED", upload_status="FAILED")
            )
            raise HTTPException(status_code=400, detail="File type not supported for OCR.")

        extracted_data = extract_financial_terms(extracted_text)
        risks = analyze_text_for_risks(extracted_text) # Simplified, removed ml_model dependency
        risk_analysis = calculate_risk_score_and_level(risks)

        analysis_data = schemas.AIAnalysisCreate(
            contract_id=contract_id,
            risk_score=risk_analysis.get("risk_score", 0.0),
            risk_level=risk_analysis.get("risk_level", "Unknown"),
            summary=risk_analysis.get("risk_explanation", ""),
        )
        
        # Save analysis to DB (assuming a relationship or direct storage)
        await crud.create_ai_analysis(db, analysis_data) # Assuming this CRUD function exists

        # Update contract status
        await crud.update_contract(
            db, contract_id, schemas.ContractUpdate(analysis_status="COMPLETED")
        )

        return {"status": "Analysis completed", "contract_id": contract_id}

    except Exception as e:
        await crud.update_contract(
            db, contract_id, schemas.ContractUpdate(analysis_status="FAILED")
        )
        raise HTTPException(
            status_code=500,
            detail=f"An error occurred during contract analysis: {e}"
        )