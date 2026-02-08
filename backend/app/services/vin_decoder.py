import requests

def decode_vin(vin: str) -> dict:
    url = f"https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/{vin}?format=json"
    response = requests.get(url)
    response.raise_for_status()
    data = response.json()

    # Extract relevant info
    results = data.get("Results", [])
    vehicle_info = {}
    for result in results:
        if result["Variable"] == "Make":
            vehicle_info["make"] = result["Value"]
        elif result["Variable"] == "Model":
            vehicle_info["model"] = result["Value"]
        elif result["Variable"] == "Model Year":
            vehicle_info["year"] = result["Value"]
        elif result["Variable"] == "Vehicle Type":
            vehicle_info["type"] = result["Value"]

    return vehicle_info

def get_vehicle_recalls(vin: str) -> list:
    url = f"https://vpic.nhtsa.dot.gov/api/vehicles/GetRecallsByVIN/{vin}?format=json"
    response = requests.get(url)

    
    if response.status_code == 404:
        return []

    response.raise_for_status()
    data = response.json()

    recalls = data.get("Results", [])
    return recalls
