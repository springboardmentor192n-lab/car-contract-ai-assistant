from fastapi import APIRouter
from pydantic import BaseModel
from app.services.price_estimator import estimate_price

router = APIRouter()

class PriceRequest(BaseModel):
    vin: str

@router.post("/price-estimate")
def get_price_estimate(data: PriceRequest):
    result = estimate_price(data.vin)
    return result
