from app.services.vin_decoder import decode_vin
from app.services.vin_lookup import get_comprehensive_vin_data

def estimate_price(vin: str) -> dict:
    """
    Get vehicle information based on VIN.
    Note: Real price estimation requires paid APIs (KBB, Edmunds, etc.)
    """
    # Decode VIN to get vehicle info
    vehicle_info = decode_vin(vin)

    return {
        "vehicle_info": vehicle_info,
        "note": "Real-time price estimation requires paid third-party APIs like Kelley Blue Book (KBB) or Edmunds. NHTSA only provides vehicle specifications and recall data."
    }

def estimate_price_with_details(vin: str) -> dict:
    """
    Get comprehensive vehicle data including recalls.
    Note: Does not include pricing - requires paid APIs.
    """
    vin_data = get_comprehensive_vin_data(vin)
    vehicle_basic = decode_vin(vin)

    return {
        "vin_data": vin_data,
        "vehicle_info": vehicle_basic,
        "note": "Real-time price estimation requires paid third-party APIs like Kelley Blue Book (KBB) or Edmunds."
    }
