import requests

def decode_vin(vin: str) -> dict:
    """
    Decode VIN using NHTSA API and return vehicle information.
    Returns a dictionary with make, model, year, and type.
    If API fails or data is not found, returns dictionary with None values.
    """
    try:
        url = f"https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/{vin}?format=json"
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        data = response.json()

        # Extract relevant info
        results = data.get("Results", [])
        vehicle_info = {
            "make": None,
            "model": None,
            "year": None,
            "type": None
        }
        
        for result in results:
            variable = result.get("Variable", "")
            value = result.get("Value", None)
            
            # Only set value if it's not None and not empty string
            if value and value.strip():
                if variable == "Make":
                    vehicle_info["make"] = value
                elif variable == "Model":
                    vehicle_info["model"] = value
                elif variable == "Model Year":
                    vehicle_info["year"] = value
                elif variable == "Vehicle Type":
                    vehicle_info["type"] = value

        return vehicle_info
    
    except requests.RequestException as e:
        print(f"Error decoding VIN {vin}: {e}")
        # Return default structure on error
        return {
            "make": None,
            "model": None,
            "year": None,
            "type": None
        }

def get_vehicle_recalls(vin: str) -> list:
    url = f"https://vpic.nhtsa.dot.gov/api/vehicles/GetRecallsByVIN/{vin}?format=json"
    response = requests.get(url)

    
    if response.status_code == 404:
        return []

    response.raise_for_status()
    data = response.json()

    recalls = data.get("Results", [])
    return recalls
