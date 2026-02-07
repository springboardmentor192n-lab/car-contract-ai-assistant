from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Annotated
import uuid

from backend import crud
from backend.models import schemas
from backend.database import get_db
from backend.services.negotiation_service import mock_llm_responder
from backend.core.security import get_current_user

router = APIRouter(
    prefix="/negotiation",
    tags=["Negotiation Chat"]
)

# --- Negotiation Thread CRUD ---
@router.post("/threads/", response_model=schemas.NegotiationThread, status_code=status.HTTP_201_CREATED)
async def create_negotiation_thread(
    thread: schemas.NegotiationThreadCreate,
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Create a new negotiation thread.
    """
    if thread.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to create thread for this user.")
    
    return await crud.get_or_create_negotiation_thread(db, user_id=thread.user_id, contract_id=thread.contract_id)

@router.get("/threads/", response_model=List[schemas.NegotiationThread])
async def read_negotiation_threads(
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    skip: int = 0,
    limit: int = 100,
):
    """
    Retrieve all negotiation threads for the authenticated user.
    """
    return await crud.get_negotiation_threads(db, user_id=current_user.id, skip=skip, limit=limit)

@router.get("/threads/{thread_id}", response_model=schemas.NegotiationThread)
async def get_negotiation_thread(
    thread_id: uuid.UUID,
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Retrieve a specific negotiation thread by its ID for the authenticated user.
    """
    db_thread = await crud.get_negotiation_thread(db, thread_id=thread_id)
    if db_thread is None or db_thread.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Negotiation thread not found")
    return db_thread

@router.put("/threads/{thread_id}", response_model=schemas.NegotiationThread)
async def update_negotiation_thread(
    thread_id: uuid.UUID,
    thread_update: schemas.NegotiationThreadUpdate,
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Update an existing negotiation thread for the authenticated user.
    """
    db_thread = await crud.get_negotiation_thread(db, thread_id=thread_id)
    if db_thread is None or db_thread.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Negotiation thread not found")
    
    return await crud.update_negotiation_thread(db=db, thread_id=thread_id, thread=thread_update)

@router.delete("/threads/{thread_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_negotiation_thread(
    thread_id: uuid.UUID,
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Delete a negotiation thread for the authenticated user.
    """
    db_thread = await crud.get_negotiation_thread(db, thread_id=thread_id)
    if db_thread is None or db_thread.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Negotiation thread not found")
    
    await crud.delete_negotiation_thread(db=db, thread_id=thread_id)
    return {"ok": True}


# --- Negotiation Message CRUD ---
@router.post("/threads/{thread_id}/messages/", response_model=schemas.NegotiationMessage)
async def create_negotiation_message(
    thread_id: uuid.UUID,
    message: schemas.NegotiationMessageCreate,
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Create a new message from a user and get an AI response.
    """
    db_thread = await crud.get_negotiation_thread(db, thread_id=thread_id)
    if db_thread is None or db_thread.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Negotiation thread not found")
    
    # Save user's message
    user_message_data = schemas.NegotiationMessageBase(
        thread_id=thread_id,
        sender_type='user',
        message_content=message.message_content
    )
    await crud.create_negotiation_message(db, message=user_message_data)

    # Get AI response
    ai_response_content = await mock_llm_responder(message.message_content)

    # Save AI's response and return it
    ai_message_data = schemas.NegotiationMessageBase(
        thread_id=thread_id,
        sender_type='ai',
        message_content=ai_response_content
    )
    return await crud.create_negotiation_message(db, message=ai_message_data)

@router.get("/threads/{thread_id}/messages/", response_model=List[schemas.NegotiationMessage])
async def read_negotiation_messages(
    thread_id: uuid.UUID,
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Retrieve all messages for a specific negotiation thread.
    """
    db_thread = await crud.get_negotiation_thread(db, thread_id=thread_id)
    if db_thread is None or db_thread.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Negotiation thread not found")

    return await crud.get_messages_by_thread_id(db, thread_id=thread_id)
