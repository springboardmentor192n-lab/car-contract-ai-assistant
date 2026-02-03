# backend/app/api/chatbot.py (UPDATED)
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional, Dict
from app.services.chatbot import SimpleChatbot
from app.core.database import get_db
from app.services.database_service import DatabaseService

router = APIRouter(prefix="/api/chatbot", tags=["chatbot"])


class ChatRequest(BaseModel):
    message: str
    session_id: str
    contract_id: Optional[int] = None


chatbots = {}


@router.post("/message")
async def send_message(
        request: ChatRequest,
        db: Session = Depends(get_db)
):
    """Send message to chatbot and save to database"""

    # Save user message to database
    DatabaseService.save_chat_message(
        db=db,
        session_id=request.session_id,
        role="user",
        message=request.message,
        contract_id=request.contract_id
    )

    # Get or create chatbot
    if request.session_id not in chatbots:
        # Get contract data if contract_id provided
        contract_data = None
        if request.contract_id:
            from app.services.database_service import DatabaseService
            contract = DatabaseService.get_contract_by_id(db, request.contract_id)
            if contract:
                contract_data = contract.to_dict()

        chatbots[request.session_id] = SimpleChatbot(contract_data)

    chatbot = chatbots[request.session_id]

    # Get response
    response = chatbot.get_response(request.message)
    tips = chatbot.get_negotiation_tips()

    # Save assistant response to database
    DatabaseService.save_chat_message(
        db=db,
        session_id=request.session_id,
        role="assistant",
        message=response,
        contract_id=request.contract_id
    )

    return {
        "session_id": request.session_id,
        "response": response,
        "tips": tips
    }


@router.get("/history/{session_id}")
async def get_chat_history(
        session_id: str,
        limit: int = 50,
        db: Session = Depends(get_db)
):
    """Get chat history for a session"""
    messages = DatabaseService.get_chat_history(db, session_id, limit)

    return {
        "session_id": session_id,
        "total_messages": len(messages),
        "messages": [m.to_dict() for m in messages]
    }