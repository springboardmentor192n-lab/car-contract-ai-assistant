
import requests
import json
from typing import Dict, Any, List

class VINService:
    BASE_URL = "https://vpic.nhtsa.dot.gov/api"

    def decode_vin(self, vin: str) -> Dict[str, Any]:
        """
        Decodes a VIN using NHTSA API.
        """
        try:
            url = f"{self.BASE_URL}/vehicles/decodevin/{vin}?format=json"
            response = requests.get(url)
            if response.status_code == 200:
                data = response.json()
                results = data.get("Results", [])
                
                # Extract key info
                info = {}
                for item in results:
                    if item.get("Variable") in ["Make", "Model", "Model Year", "Manufacturer Name", "Plant City"]:
                        info[item.get("Variable")] = item.get("Value")
                
                return {
                    "vin": vin,
                    "make": info.get("Make"),
                    "model": info.get("Model"),
                    "year": int(info.get("Model Year")) if info.get("Model Year") else None,
                    "manufacturer": info.get("Manufacturer Name"),
                    "plant_city": info.get("Plant City")
                }
            return {}
        except Exception as e:
            print(f"VIN Decode Error: {e}")
            return {}

    def get_recalls(self, make: str, model: str, year: int) -> List[Dict[str, Any]]:
        """
        Fetches recalls for a vehicle.
        Note: The proper API for detailed recall by VIN is different and sometimes restricted.
        We will use the vehicle make/model/year approach for simplicity.
        """
        try:
            # https://api.nhtsa.gov/recalls/recallsByVehicle?make=acura&model=rdx&modelYear=2012
            # Note: vpic is different from api.nhtsa.gov. Let's stick to a safe mock if actual API is flaky, 
            # but let's try strict params.
            
            # Using a simplified mock response for recalls if API fails or for demo purposes
            # Real implementation would require hitting `https://api.nhtsa.gov/recalls/recallsByVehicle`
            
            url = f"https://api.nhtsa.gov/recalls/recallsByVehicle?make={make}&model={model}&modelYear={year}"
            response = requests.get(url)
            
            if response.status_code == 200:
                data = response.json()
                return data.get("results", [])
            
            return []
        except Exception as e:
            print(f"Recall Fetch Error: {e}")
            return []

vin_service = VINService()
