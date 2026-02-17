def estimate_vehicle_price(vehicle: dict) -> dict:
    """
    Rule-based vehicle price estimation using basic vehicle details.
    Designed for academic/demo use (proposal-aligned).
    """

    # -----------------------------
    # Extract required fields
    # -----------------------------
    make = (vehicle.get("Make") or "").strip().lower()
    model_year = vehicle.get("ModelYear")

    try:
        year = int(model_year)
    except (TypeError, ValueError):
        return {
            "error": "Invalid or missing ModelYear for price estimation"
        }

    # -----------------------------
    # Base price table (₹, approx market averages)
    # -----------------------------
    base_prices = {
        "honda": 800000,
        "toyota": 850000,
        "hyundai": 750000,
        "maruti": 700000,
        "kia": 820000,
        "tata": 730000,
        "mahindra": 760000
    }

    base_price = base_prices.get(make, 780000)  # default average

    # -----------------------------
    # Depreciation logic
    # -----------------------------
    CURRENT_YEAR = 2025
    age = max(CURRENT_YEAR - year, 0)

    # ₹40,000 depreciation per year
    depreciation = age * 40000
    estimated_price = max(base_price - depreciation, 300000)

    # -----------------------------
    # Market positioning
    # -----------------------------
    if estimated_price < 500000:
        market_position = "Underpriced"
    elif estimated_price > 900000:
        market_position = "Overpriced"
    else:
        market_position = "Fair Market Price"

    # -----------------------------
    # Final response
    # -----------------------------
    return {
        "make": make.title(),
        "model_year": year,
        "vehicle_age_years": age,
        "estimated_price_range": f"₹{estimated_price - 50000:,} – ₹{estimated_price + 50000:,}",
        "estimated_price_min": estimated_price - 50000,
        "estimated_price_max": estimated_price + 50000,
        "market_position": market_position,
        "estimation_note": "Price is an approximate market estimate based on make and vehicle age"
    }
