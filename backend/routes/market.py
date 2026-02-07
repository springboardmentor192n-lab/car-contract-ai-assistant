from fastapi import APIRouter, Depends, HTTPException, status, Query
from typing import Any, List, Annotated
from sqlalchemy.ext.asyncio import AsyncSession
import uuid
from datetime import datetime, timedelta
import random

from backend.database import get_db
from backend.services.market_data import generate_mock_price_range
from backend import crud
from backend.models import schemas
from backend.core.security import get_current_user

router = APIRouter(
    prefix="/market",
    tags=["Market Data"]
)

# --- Vehicle Price Benchmark CRUD ---
@router.post("/benchmarks/", response_model=schemas.VehiclePriceBenchmark, status_code=status.HTTP_201_CREATED)
async def create_vehicle_price_benchmark(
    benchmark: schemas.VehiclePriceBenchmarkCreate,
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Create a new vehicle price benchmark.
    """
    return await crud.create_vehicle_price_benchmark(db=db, benchmark=benchmark)

@router.get("/benchmarks/", response_model=List[schemas.VehiclePriceBenchmark])
async def read_all_vehicle_price_benchmarks(
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    skip: int = 0,
    limit: int = 100
):
    """
    Retrieve a list of all vehicle price benchmarks.
    """
    return await crud.get_all_vehicle_price_benchmarks(db, skip=skip, limit=limit)

@router.get("/benchmarks/{benchmark_id}", response_model=schemas.VehiclePriceBenchmark)
async def get_vehicle_price_benchmark(
    benchmark_id: uuid.UUID,
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Retrieve a specific vehicle price benchmark by its ID.
    """
    db_benchmark = await crud.get_vehicle_price_benchmark(db, benchmark_id=benchmark_id)
    if db_benchmark is None:
        raise HTTPException(status_code=404, detail="Vehicle price benchmark not found")
    return db_benchmark

@router.put("/benchmarks/{benchmark_id}", response_model=schemas.VehiclePriceBenchmark)
async def update_vehicle_price_benchmark(
    benchmark_id: uuid.UUID,
    benchmark_update: schemas.VehiclePriceBenchmarkUpdate,
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Update an existing vehicle price benchmark.
    """
    db_benchmark = await crud.get_vehicle_price_benchmark(db, benchmark_id=benchmark_id)
    if db_benchmark is None:
        raise HTTPException(status_code=404, detail="Vehicle price benchmark not found")
    
    return await crud.update_vehicle_price_benchmark(db=db, benchmark_id=benchmark_id, benchmark=benchmark_update)

@router.delete("/benchmarks/{benchmark_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_vehicle_price_benchmark(
    benchmark_id: uuid.UUID,
    current_user: Annotated[schemas.User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Delete a vehicle price benchmark.
    """
    db_benchmark = await crud.get_vehicle_price_benchmark(db, benchmark_id=benchmark_id)
    if db_benchmark is None:
        raise HTTPException(status_code=404, detail="Vehicle price benchmark not found")
    
    await crud.delete_vehicle_price_benchmark(db=db, benchmark_id=benchmark_id)
    return {"ok": True}

# --- Price Lookup Endpoint ---
@router.get("/price", response_model=schemas.PriceBenchmarkResponse)
async def get_price_benchmark_from_cache(
    db: Annotated[AsyncSession, Depends(get_db)],
    make: str = Query(..., min_length=2, description="Vehicle make (e.g., 'Toyota')"),
    model: str = Query(..., min_length=1, description="Vehicle model (e.g., 'Camry')"),
    year: int = Query(..., gt=1980, lt=datetime.now().year + 2, description="Vehicle year (e.g., 2021)")
):
    """
    Get the price benchmark for a vehicle.
    - If a benchmark exists in the cache, it's returned.
    - If not, a mock price range is generated, saved, and then returned.
    """
    cached_benchmark = await crud.get_benchmark_from_cache(db, make=make, model=model, year=year)
    if cached_benchmark:
        return cached_benchmark

    mock_data = generate_mock_price_range(make=make, model=model, year=year)

    benchmark_to_create = schemas.PriceBenchmarkCacheCreate(**mock_data, make=make, model=model, year=year)
    new_benchmark = await crud.create_benchmark_in_cache(db, benchmark_data=benchmark_to_create)

    return new_benchmark

# --- Market Rates Endpoint ---
@router.get("/rates", response_model=schemas.MarketRatesResponse)
async def get_market_rates():
    """
    Returns simulated market interest rates and historical data.
    """
    # Generate simulated historical data with a more consistent trend
    historical_data = []
    current_date = datetime.now()
    base_rate = 4.5 # Starting base rate
    
    for i in range(6, -1, -1): # Last 6 months plus current
        month_date = current_date - timedelta(days=30 * i)
        
        # Introduce a slight trend over time
        rate_fluctuation = (random.random() * 0.4) - 0.2 # +/- 0.2% fluctuation
        trend = (6 - i) * 0.05 # Small increase over months
        
        rate = base_rate + rate_fluctuation + trend
        historical_data.append(schemas.HistoricalRate(
            date=month_date.strftime("%Y-%m-%d"),
            interest_rate=round(rate, 2)
        ))
    
    latest_apr = historical_data[-1].interest_rate
    change_from_previous = latest_apr - historical_data[-2].interest_rate if len(historical_data) > 1 else 0.0

    return schemas.MarketRatesResponse(
        latest_apr=round(latest_apr, 2),
        change_from_previous=round(change_from_previous, 2),
        last_updated=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        historical_data=historical_data
    )