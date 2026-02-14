import requests


def verify_vin_with_nhtsa(vin):
    """
    Calls NHTSA VIN API and returns decoded vehicle details.
    """

    if not vin:
        return None

    url = f"https://vpic.nhtsa.dot.gov/api/vehicles/decodevinvalues/{vin}?format=json"

    try:
        response = requests.get(url)
        data = response.json()

        if data["Results"]:
            result = data["Results"][0]

            return {
                "Make": result.get("Make"),
                "Model": result.get("Model"),
                "ModelYear": result.get("ModelYear"),
                "BodyClass": result.get("BodyClass"),
                "EngineModel": result.get("EngineModel")
            }

    except Exception:
        return None
