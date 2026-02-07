from fastapi import APIRouter, Depends, HTTPException, status, Query
from typing import Any, List, Annotated
from sqlalchemy.ext.asyncio import AsyncSession
import uuid

from backend.database import get_db
from backend.services.vin_lookup import vin_lookup_service
from backend.models import schemas
from backend import crud
from backend.core.security import get_current_user

router = APIRouter(
    prefix="/vin",
    tags=["VIN Lookup"]
)

@router.post("/vehicles/", response_model=schemas.Vehicle, status_code=status.HTTP_201_CREATED)
async def create_vehicle(
    vehicle: schemas.VehicleCreate,
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Create a new vehicle entry.
    """
    return await crud.create_vehicle(db=db, vehicle=vehicle)

@router.get("/vehicles/", response_model=List[schemas.Vehicle])
async def read_vehicles(
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    skip: int = 0,
    limit: int = 100
):
    """
    Retrieve a list of all vehicles.
    """
    return await crud.get_vehicles(db, skip=skip, limit=limit)

@router.get("/vehicles/{vehicle_id}", response_model=schemas.Vehicle)
async def get_vehicle(
    vehicle_id: uuid.UUID,
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Retrieve a specific vehicle by its ID.
    """
    db_vehicle = await crud.get_vehicle(db, vehicle_id=vehicle_id)
    if db_vehicle is None:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    return db_vehicle

@router.put("/vehicles/{vehicle_id}", response_model=schemas.Vehicle)
async def update_vehicle(
    vehicle_id: uuid.UUID,
    vehicle_update: schemas.VehicleUpdate,
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Update an existing vehicle.
    """
    db_vehicle = await crud.get_vehicle(db, vehicle_id=vehicle_id)
    if db_vehicle is None:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    
    return await crud.update_vehicle(db=db, vehicle_id=vehicle_id, vehicle=vehicle_update)

@router.delete("/vehicles/{vehicle_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_vehicle(
    vehicle_id: uuid.UUID,
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Delete a vehicle.
    """
    db_vehicle = await crud.get_vehicle(db, vehicle_id=vehicle_id)
    if db_vehicle is None:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    
    await crud.delete_vehicle(db=db, vehicle_id=vehicle_id)
    return {"ok": True}

@router.get("/lookup/{vin_number}", response_model=schemas.VINLookupResponse)
async def vin_lookup_route(
    vin_number: str,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[schemas.User, Depends(get_current_user)] # Added for consistency
):
    """
    Performs a VIN lookup and returns vehicle details and a report.
    """
    return await vin_lookup_service(db, vin_number)