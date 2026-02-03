# backend/app/services/vin_service.py
import requests
from typing import Dict


class SimpleVINService:
    def __init__(self):
        self.base_url = "https://vpic.nhtsa.dot.gov/api/vehicles"

    def decode_vin(self, vin: str) -> Dict:
        """Simple VIN decoding using NHTSA API"""

        # Clean VIN
        vin = vin.strip().upper()

        if len(vin) != 17:
            return {
                "error": "VIN must be 17 characters",
                "valid": False
            }

        try:
            # Call NHTSA API
            url = f"{self.base_url}/DecodeVinValues/{vin}?format=json"
            response = requests.get(url, timeout=10)
            data = response.json()

            if data.get("Results"):
                result = data["Results"][0]

                # Get recall info
                recalls = self._get_recalls(vin)

                return {
                    "valid": True,
                    "vin": vin,
                    "make": result.get("Make", "Unknown"),
                    "model": result.get("Model", "Unknown"),
                    "year": result.get("ModelYear", "Unknown"),
                    "body_type": result.get("BodyClass", "Unknown"),
                    "engine": result.get("EngineModel", "Unknown"),
                    "recalls": recalls,
                    "source": "NHTSA API"
                }
            else:
                return {
                    "valid": False,
                    "error": "No data returned from API"
                }

        except Exception as e:
            return {
                "valid": False,
                "error": str(e)
            }

    def _get_recalls(self, vin: str) -> Dict:
        """Get recall information"""
        try:
            url = f"{self.base_url}/RecallsByVehicle?vin={vin}&format=json"
            response = requests.get(url, timeout=5)
            data = response.json()

            if data.get("Count", 0) > 0:
                recalls = []
                for item in data.get("Results", [])[:3]:  # Limit to 3
                    recalls.append({
                        "description": item.get("Summary", "No description"),
                        "date": item.get("ReportReceivedDate", "Unknown")
                    })

                return {
                    "count": data.get("Count", 0),
                    "recalls": recalls
                }
        except:
            pass

        return {"count": 0, "recalls": []}


# Mock service for testing
class MockVINService:
    def decode_vin(self, vin: str) -> Dict:
        return {
            "valid": True,
            "vin": vin,
            "make": "Toyota",
            "model": "Camry",
            "year": "2023",
            "body_type": "Sedan",
            "engine": "2.5L 4-cylinder",
            "recalls": {
                "count": 2,
                "recalls": [
                    {"description": "Software update required", "date": "2023-05-15"},
                    {"description": "Airbag sensor check", "date": "2023-08-22"}
                ]
            },
            "market_value": "$25,000 - $28,000",
            "source": "Mock Data"
        }