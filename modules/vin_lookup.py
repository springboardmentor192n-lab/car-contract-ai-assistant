import requests

def lookup_vin(vin):
    if not vin or len(str(vin)) < 10 or "ERROR" in str(vin).upper():
        return {}
    try:
        url = f"https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/{vin}?format=json"
        response = requests.get(url, timeout=10).json()
        vin_data = {}
        for item in response.get("Results", []):
            if item["Variable"] in ["Make", "Model", "Model Year", "Manufacturer Name"]:
                vin_data[item["Variable"].lower().replace(" ", "_")] = item["Value"]
        return vin_data
    except:
        return {}


