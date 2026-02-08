from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
from app.services.chat_prompt import build_chat_prompt
from app.services.llm_extractor import call_llm
from app.services.price_estimator import estimate_vehicle_price

router = APIRouter()

class ChatRequest(BaseModel):
    sla_data: Optional[dict] = None
    question: str
    vehicle: dict | None = None

@router.post("/chat")
def chat_with_contract(data: ChatRequest):
    price_context = None

    if data.vehicle:
        try:
            price_context = estimate_vehicle_price(
                make=data.vehicle.get("make"),
                model=data.vehicle.get("model"),
                year=int(data.vehicle.get("year")),
                location=""
            )
        except Exception:
            price_context = None

    prompt = build_chat_prompt(
        contract_sla=data.sla_data,
        user_question=data.question,
        price_context=price_context,
    )

    response = call_llm(prompt)
    return {"answer": response}
