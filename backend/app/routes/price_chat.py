from fastapi import APIRouter
from pydantic import BaseModel
from app.services.price_estimator import estimate_price_with_details

router = APIRouter()

class PriceChatRequest(BaseModel):
    vin: str

@router.post("/price-chat")
def get_price_chat_estimate(data: PriceChatRequest):
    result = estimate_price_with_details(data.vin)
    return result
