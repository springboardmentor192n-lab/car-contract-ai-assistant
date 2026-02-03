# backend/app/api/vin.py (UPDATED)
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.services.vin_service import SimpleVINService, MockVINService
from app.core.database import get_db
from app.services.database_service import DatabaseService

router = APIRouter(prefix="/api/vin", tags=["vin"])


@router.get("/decode/{vin}")
async def decode_vin(
        vin: str,
        use_mock: bool = True,
        use_cache: bool = True,
        db: Session = Depends(get_db)
):
    """Decode VIN with caching"""

    # Check cache first
    if use_cache:
        cached = DatabaseService.get_vehicle_info(db, vin)
        if cached:
            return {
                **cached.to_dict(),
                "source": "database_cache",
                "cached": True
            }

    # Get from service
    service = MockVINService() if use_mock else SimpleVINService()
    result = service.decode_vin(vin)

    if not result.get("valid"):
        raise HTTPException(400, f"Invalid VIN: {result.get('error', 'Unknown error')}")

    # Save to database cache
    if use_cache and result.get("valid"):
        vehicle_data = {
            "make": result.get("make"),
            "model": result.get("model"),
            "year": result.get("year"),
            "body_type": result.get("body_type"),
            "recall_count": result.get("recalls", {}).get("count", 0)
        }
        DatabaseService.save_vehicle_info(db, vin, vehicle_data)

    return result