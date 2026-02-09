# vin_lookup.py
import requests

def lookup_vin(vin: str):
    url = f"https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/{vin}?format=json"
    res = requests.get(url)
    data = res.json()

    result = {}
    for item in data["Results"]:
        if item["Value"]:
            result[item["Variable"]] = item["Value"]

    return result
