from fastapi import HTTPException
import httpx
from typing import Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
import uuid

from backend.utils.helpers import VIN_REGEX
from backend.models import schemas
from backend import crud

async def vin_lookup_service(db: AsyncSession, vin: str) -> schemas.VINLookupResponse:
    if not VIN_REGEX.match(vin):
        raise HTTPException(
            status_code=400,
            detail="Invalid VIN. Must be 17 chars and exclude I, O, Q."
        )

    # Check if vehicle exists
    db_vehicle = await crud.get_vehicle_by_vin(db, vin=vin)

    url = f"https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues/{vin}?format=json"

    try:
        async with httpx.AsyncClient() as client:
            resp = await client.get(url, timeout=10)
            resp.raise_for_status()
            data = resp.json()

        results = data.get("Results")
        if not results or not isinstance(results, list):
            raise HTTPException(status_code=400, detail="Invalid VIN data from API")

        info = results[0]

        if info.get("ErrorCode") != "0" and not info.get("ErrorCode").startswith("1,"): # Ignore partial success errors
            raise HTTPException(
                status_code=400,
                detail=f"Error decoding VIN: {info.get('ErrorText', 'Unknown error')}"
            )
        
        # If vehicle didn't exist, create it
        if not db_vehicle:
            vehicle_in = schemas.VehicleCreate(
                vin=vin,
                make=info.get("Make"),
                model=info.get("Model"),
                year=info.get("ModelYear"),
                body_type=info.get("BodyClass"),
                fuel_type=info.get("FuelTypePrimary"),
                engine=info.get("EngineCylinders"),
                plant_country=info.get("PlantCountry"),
            )
            db_vehicle = await crud.create_vehicle(db, vehicle=vehicle_in)

        # Create a new report for this lookup
        report_in = schemas.VINReportCreate(
            vehicle_id=db_vehicle.id,
            source="NHTSA",
            raw_response=info
            # In a real app, you would parse more fields here like recalls, accidents etc.
        )
        db_report = await crud.create_vin_report(db, report=report_in)

        return schemas.VINLookupResponse(vehicle=db_vehicle, report=db_report)

    except httpx.RequestError:
        raise HTTPException(
            status_code=503,
            detail="VIN service unavailable"
        )