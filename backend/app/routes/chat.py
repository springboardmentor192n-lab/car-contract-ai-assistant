from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
from app.services.chat_prompt import build_chat_prompt
from app.services.llm_extractor import call_llm

router = APIRouter()

class ChatRequest(BaseModel):
    sla_data: Optional[dict] = None
    question: str
    vehicle: dict | None = None

@router.post("/chat")
def chat_with_contract(data: ChatRequest):
    """
    Chat endpoint for contract analysis.
    Note: Price context removed - was using mock data.
    """
    prompt = build_chat_prompt(
        contract_sla=data.sla_data,
        user_question=data.question,
        vehicle_details=data.vehicle,
        price_context=None,  # No longer providing mock price data
    )

    response = call_llm(prompt)
    return {"answer": response}
