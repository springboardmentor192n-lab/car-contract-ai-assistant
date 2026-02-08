from app.services.vin_decoder import decode_vin
from app.services.vin_lookup import get_comprehensive_vin_data

def estimate_vehicle_price(make: str, model: str, year: int, location: str = "") -> dict:
    # Mock price estimation based on make, model, year
    # In a real app, this would use an API like Kelley Blue Book or Edmunds
    base_price = 25000  # Base price for average car

    # Adjust based on year (newer cars are more expensive)
    year_adjustment = (year - 2020) * 1000

    # Adjust based on make (some makes are premium)
    make_lower = make.lower()
    if "bmw" in make_lower or "mercedes" in make_lower or "audi" in make_lower:
        make_adjustment = 10000
    elif "toyota" in make_lower or "honda" in make_lower:
        make_adjustment = 2000
    else:
        make_adjustment = 0

    estimated_min = base_price + year_adjustment + make_adjustment - 5000
    estimated_max = base_price + year_adjustment + make_adjustment + 5000

    return {
        "estimated_price_range": {
            "min": max(0, estimated_min),
            "max": estimated_max
        },
        "vehicle": {
            "make": make,
            "model": model,
            "year": year
        }
    }

def estimate_price(vin: str) -> dict:
    # Decode VIN to get vehicle info
    vehicle_info = decode_vin(vin)

    # Mock price estimation based on make, model, year
    # In a real app, this would use an API like Kelley Blue Book or Edmunds
    base_price = 25000  # Base price for average car

    # Adjust based on year (newer cars are more expensive)
    year_str = vehicle_info.get("year")
    year = int(year_str) if year_str else 2020
    year_adjustment = (year - 2020) * 1000

    # Adjust based on make (some makes are premium)
    make = vehicle_info.get("make", "").lower()
    if "bmw" in make or "mercedes" in make or "audi" in make:
        make_adjustment = 10000
    elif "toyota" in make or "honda" in make:
        make_adjustment = 2000
    else:
        make_adjustment = 0

    estimated_min = base_price + year_adjustment + make_adjustment - 5000
    estimated_max = base_price + year_adjustment + make_adjustment + 5000

    # Mock lease deal benchmarks
    lease_monthly_min = estimated_min // 60  # 5-year lease
    lease_monthly_max = estimated_max // 60
    lease_down_payment_min = estimated_min * 0.1
    lease_down_payment_max = estimated_max * 0.1

    return {
        "vehicle_info": vehicle_info,
        "price_estimate": {
            "estimated_price_range": {
                "min": max(0, estimated_min),
                "max": estimated_max
            },
            "lease_benchmarks": {
                "monthly_payment_range": {
                    "min": lease_monthly_min,
                    "max": lease_monthly_max
                },
                "down_payment_range": {
                    "min": lease_down_payment_min,
                    "max": lease_down_payment_max
                }
            }
        }
    }

def estimate_price_with_details(vin: str) -> dict:
    vin_data = get_comprehensive_vin_data(vin)
    price_data = estimate_price(vin)

    return {
        "vin_data": vin_data,
        "price_data": price_data
    }
