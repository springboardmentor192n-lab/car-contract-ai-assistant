from fastapi import APIRouter, File, UploadFile, Depends, HTTPException, status, Query
from fastapi.concurrency import run_in_threadpool
from typing import Any, Dict, List, Annotated
from sqlalchemy.ext.asyncio import AsyncSession
import os
import uuid

from backend import crud
from backend.models import schemas
from backend.database import get_db
from backend.services.contract_analysis import analyze_contract_service
from backend.services.ask_ai_service import ask_ai_service
from backend.core.security import get_current_user

router = APIRouter(
    prefix="/contracts",
    tags=["contracts"]
)

UPLOADS_DIR = "backend/uploads"

@router.post("/", response_model=schemas.Contract, status_code=status.HTTP_201_CREATED)
async def create_contract(
    contract: schemas.ContractCreate, 
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Create a new contract record. This is for DB entry only.
    """
    # Ensure the contract is associated with the authenticated user
    if contract.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Cannot create a contract for another user.")
    
    return await crud.create_contract(db=db, contract=contract)

@router.get("/", response_model=List[schemas.Contract])
async def read_contracts(
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    skip: int = 0,
    limit: int = 100
):
    """
    Retrieve all contracts for the authenticated user.
    """
    return await crud.get_contracts(db, user_id=current_user.id, skip=skip, limit=limit)

@router.get("/{contract_id}", response_model=schemas.Contract)
async def get_contract(
    contract_id: uuid.UUID, 
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Retrieve a specific contract by its ID for the authenticated user.
    """
    db_contract = await crud.get_contract(db, contract_id=contract_id)
    if db_contract is None or db_contract.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Contract not found")
    return db_contract

@router.put("/{contract_id}", response_model=schemas.Contract)
async def update_contract(
    contract_id: uuid.UUID,
    contract_update: schemas.ContractUpdate,
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Update an existing contract for the authenticated user.
    """
    db_contract = await crud.get_contract(db, contract_id=contract_id)
    if db_contract is None or db_contract.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Contract not found")
    
    return await crud.update_contract(db=db, contract_id=contract_id, contract=contract_update)

@router.delete("/{contract_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_contract(
    contract_id: uuid.UUID,
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Delete a contract for the authenticated user.
    """
    db_contract = await crud.get_contract(db, contract_id=contract_id)
    if db_contract is None or db_contract.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Contract not found")
    
    await crud.delete_contract(db=db, contract_id=contract_id)
    return {"ok": True}

@router.post("/ask_ai", response_model=schemas.AskAIResponse)
async def ask_ai(
    request: schemas.AskAIRequest,
    current_user: Annotated[schemas.User, Depends(get_current_user)]
):
    """
    Ask the AI a question about a contract context.
    """
    answer = await ask_ai_service(request)
    return {"answer": answer}

@router.post("/analyze_upload", response_model=schemas.Contract)
async def analyze_upload_contract(
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    file: UploadFile = File(...)
):
    """
    Uploads a contract file, saves it, creates a contract record, and initiates analysis.
    """
    if not os.path.exists(UPLOADS_DIR):
        os.makedirs(UPLOADS_DIR)

    file_extension = os.path.splitext(file.filename)[1]
    if file.content_type != "application/pdf":
        raise HTTPException(status_code=400, detail="Only PDF files are allowed.")

    file_id = uuid.uuid4()
    file_location = os.path.join(UPLOADS_DIR, f"{file_id}{file_extension}")

    try:
        contents = await file.read()
        with open(file_location, "wb") as f:
            f.write(contents)

        contract_create = schemas.ContractCreate(
            user_id=current_user.id,
            file_path=file_location,
            file_name=file.filename,
            upload_status="UPLOADED",
            analysis_status="PENDING",
            contract_type="UNKNOWN"
        )
        db_contract = await crud.create_contract(db=db, contract=contract_create)

        # In a real app, use a background task runner like Celery.
        # run_in_threadpool is a simple alternative for non-blocking IO-bound tasks.
        await run_in_threadpool(analyze_contract_service, db=db, contract_id=db_contract.id)

        return db_contract
    except Exception as e:
        if os.path.exists(file_location):
            os.remove(file_location)
        raise HTTPException(status_code=500, detail=f"Failed to upload or analyze contract: {e}")