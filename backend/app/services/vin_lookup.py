from app.services.vin_decoder import decode_vin, get_vehicle_recalls

def get_comprehensive_vin_data(vin: str) -> dict:
    """
    Get comprehensive vehicle data from NHTSA API.
    Returns only real data - no mock/simulated information.
    """
    vehicle_info = decode_vin(vin)
    recalls = get_vehicle_recalls(vin)

    return {
        "vehicle_info": vehicle_info,
        "recalls": recalls,
        "note": "Only real NHTSA data is shown. Accident history, service records, and odometer data require paid third-party services."
    }
