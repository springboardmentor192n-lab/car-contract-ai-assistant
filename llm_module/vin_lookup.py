import requests

def fetch_vehicle_details_from_vin(vin):
    url = f"https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin/{vin}?format=json"

    response = requests.get(url)
    data = response.json()

    vehicle_info = {
        "make": "",
        "model": "",
        "year": ""
    }

    for item in data.get("Results", []):
        if item["Variable"] == "Make":
            vehicle_info["make"] = item["Value"]
        elif item["Variable"] == "Model":
            vehicle_info["model"] = item["Value"]
        elif item["Variable"] == "Model Year":
            vehicle_info["year"] = item["Value"]

    return vehicle_info
