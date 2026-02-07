from fastapi import HTTPException
import httpx
from typing import Dict, Any, List
import logging
import random
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timedelta

from backend.config import settings
from backend.models import schemas
from backend import crud

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def generate_mock_price_range(make: str, model: str, year: int) -> Dict[str, float]:
    """
    Generates a simulated price range for a vehicle based on its year.
    This is a placeholder for a real market data API.
    """
    logger.info(f"Generating simulated price data for {year} {make} {model}")
    
    # Create a deterministic seed from the car details
    seed = hash(f"{make.lower()}-{model.lower()}-{year}")
    rand = random.Random(seed)
    
    # Base price influenced by year
    current_year = datetime.now().year
    year_diff = current_year - year
    
    # More predictable base prices
    if year_diff < 0: # Car from the future?
        base_price = 50000.0
    elif year_diff <= 1: # New or very recent
        base_price = 35000.0
    elif year_diff <= 3:
        base_price = 25000.0
    elif year_diff <= 5:
        base_price = 18000.0
    elif year_diff <= 10:
        base_price = 10000.0
    else: # Older than 10 years
        base_price = 5000.0

    # Add some consistent variability based on make/model hash
    # Use a smaller, fixed spread for more realism
    variability = (seed % 2000) - 1000 # +/- 1000
    base_price += variability
    
    # Define price range
    spread = base_price * 0.05 # 5% spread
    min_price = base_price - spread
    max_price = base_price + spread
    avg_price = (min_price + max_price) / 2

    return {
        "min_price": round(max(0, min_price), 2), # Ensure price is not negative
        "max_price": round(max_price, 2),
        "avg_price": round(max(0, avg_price), 2),
    }

