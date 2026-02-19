
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, BackgroundTasks
from sqlalchemy.orm import Session, joinedload
import models, schemas, database
from routers.auth import get_current_user
from services.ocr_service import ocr_service
from services.llm_extraction_service import llm_service
from services.vin_service import vin_service
from services.price_estimation_service import price_service
from services.fairness_score_service import fairness_service
import shutil
import os
import uuid
from datetime import datetime

router = APIRouter(prefix="/contracts", tags=["Contracts"])

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

async def process_contract_task(contract_id: int, file_path: str, filename: str):
    db = database.SessionLocal()
    try:
        contract = db.query(models.Contract).filter(models.Contract.id == contract_id).first()
        contract.status = "processing"
        db.commit()

        # 1. OCR
        text = await ocr_service.extract_text_from_file(file_path, filename)
        
        # 2. LLM Extraction
        extracted_data = await llm_service.extract_data(text)
        
        if "error" in extracted_data:
            contract.status = "failed"
            db.commit()
            return

        # Save Extracted SLA with new structured fields
        sla_model = models.ExtractedSLA(
            contract_id=contract_id,
            simple_language_summary=extracted_data.get("summary"),
            important_terms=extracted_data.get("important_terms"),
            red_flags=extracted_data.get("risky_clauses"),
            hidden_charges=extracted_data.get("hidden_charges"),
            penalties=extracted_data.get("penalties"),
            negotiation_points=extracted_data.get("negotiation_points"),
            final_advice=extracted_data.get("final_advice"),
            risk_level="Moderate"
        )
        db.add(sla_model)
        db.commit()
        db.refresh(sla_model)

        contract.status = "completed"
        db.commit()

    except Exception as e:
        import traceback
        error_msg = f"Error processing contract {contract_id}: {str(e)}\n{traceback.format_exc()}"
        print(error_msg)
        with open("backend_errors.log", "a") as f:
            f.write(f"[{datetime.now()}] {error_msg}\n")
            
        contract = db.query(models.Contract).filter(models.Contract.id == contract_id).first()
        if contract:
            contract.status = "failed"
            db.commit()
    finally:
        db.close()

@router.post("/upload", response_model=schemas.Contract)
async def upload_contract(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    # Ensure upload directory
    upload_dir = "uploads"
    if not os.path.exists(upload_dir):
        os.makedirs(upload_dir)
        
    file_path = f"{upload_dir}/{uuid.uuid4()}_{file.filename}"
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    # Create Contract Record
    db_contract = models.Contract(
        user_id=None,
        filename=file.filename,
        file_path=file_path,
        status="queued"
    )
    db.add(db_contract)
    db.commit()
    db.refresh(db_contract)
    
    # Trigger Background Processing
    background_tasks.add_task(process_contract_task, db_contract.id, file_path, file.filename)
    
    return db_contract

@router.get("", response_model=list[schemas.Contract])
def get_contracts(db: Session = Depends(get_db)):
    return db.query(models.Contract).options(
        joinedload(models.Contract.sla),
        joinedload(models.Contract.vehicle_report),
        joinedload(models.Contract.price_analysis),
        joinedload(models.Contract.fairness_score)
    ).all()

@router.get("/{contract_id}", response_model=schemas.Contract)
def get_contract_details(contract_id: int, db: Session = Depends(get_db)):
    contract = db.query(models.Contract).options(
        joinedload(models.Contract.sla),
        joinedload(models.Contract.vehicle_report),
        joinedload(models.Contract.price_analysis),
        joinedload(models.Contract.fairness_score)
    ).filter(models.Contract.id == contract_id).first()
    if not contract:
        raise HTTPException(status_code=404, detail="Contract not found")
    return contract

@router.post("/{contract_id}/chat", response_model=schemas.NegotiationChatResponse)
async def chat_with_contract(
    contract_id: int, 
    request: schemas.NegotiationChatRequest,
    db: Session = Depends(get_db)
):
    from services.negotiation_service import negotiation_service
    
    contract = db.query(models.Contract).filter(models.Contract.id == contract_id).first()
    if not contract or not contract.sla:
        raise HTTPException(status_code=404, detail="Contract analysis not found")
        
    context = {
        "summary": contract.sla.simple_language_summary,
        "risks": contract.sla.red_flags,
        "penalties": contract.sla.penalties,
        "negotiation_points": contract.sla.negotiation_points
    }
    
    result = await negotiation_service.generate_response(context, [], request.user_message)
    return result

@router.get("/{contract_id}/download")
async def download_report(contract_id: int, db: Session = Depends(get_db)):
    from fpdf import FPDF
    import tempfile
    from fastapi.responses import FileResponse

    contract = db.query(models.Contract).filter(models.Contract.id == contract_id).first()
    if not contract or not contract.sla:
        raise HTTPException(status_code=404, detail="Contract analysis not found")

    sla = contract.sla
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Arial", "B", 16)
    pdf.cell(0, 10, f"Contract Analysis Report: {contract.filename}", ln=True, align="C")
    pdf.ln(10)

    pdf.set_font("Arial", "B", 12)
    pdf.cell(0, 10, "Summary", ln=True)
    pdf.set_font("Arial", "", 10)
    pdf.multi_cell(0, 5, sla.simple_language_summary)
    pdf.ln(5)

    sections = [
        ("Important Terms", sla.important_terms),
        ("Risky Clauses", sla.red_flags),
        ("Hidden Charges", [f"{c['name']}: {c['amount']} - {c['description']}" for c in sla.hidden_charges] if sla.hidden_charges else []),
        ("Penalties", sla.penalties),
        ("Negotiation Points", sla.negotiation_points),
    ]

    for title, items in sections:
        if items:
            pdf.set_font("Arial", "B", 12)
            pdf.cell(0, 10, title, ln=True)
            pdf.set_font("Arial", "", 10)
            for item in items:
                pdf.multi_cell(0, 5, f"- {item}")
            pdf.ln(5)

    pdf.set_font("Arial", "B", 12)
    pdf.cell(0, 10, "Final Advice", ln=True)
    pdf.set_font("Arial", "", 10)
    pdf.multi_cell(0, 5, sla.final_advice)

    with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp:
        pdf.output(tmp.name)
        return FileResponse(tmp.name, filename=f"Report_{contract.filename}.pdf")
