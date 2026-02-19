
from fastapi import APIRouter, Depends
from services.vin_service import vin_service
import schemas

router = APIRouter(prefix="/vin", tags=["VIN"])

@router.get("/decode/{vin}", response_model=schemas.VehicleReportBase)
def decode_vin_endpoint(vin: str):
    info = vin_service.decode_vin(vin)
    recalls = []
    if info.get("make") and info.get("model"):
        recalls = vin_service.get_recalls(info["make"], info["model"], info.get("year", 2024))
    
    return {
        "vin": vin,
        "make": info.get("make"),
        "model": info.get("model"),
        "year": info.get("year"),
        "manufacturer": info.get("manufacturer"),
        "recalls": recalls
    }
