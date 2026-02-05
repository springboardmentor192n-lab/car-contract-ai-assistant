import requests

def fetch_vehicle_details(vin):
    if not vin:
        return {}

    url = f"https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/{vin}?format=json"
    response = requests.get(url)

    if response.status_code != 200:
        return {}

    data = response.json().get("Results", [])

    details = {}
    for item in data:
        if item["Variable"] in ["Make", "Model", "Model Year", "Body Class"]:
            details[item["Variable"]] = item["Value"]

    return details