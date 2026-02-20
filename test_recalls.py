import requests
import json

BASE_URL = "http://127.0.0.1:8000"

def check_recalls(vin):
    url = f"{BASE_URL}/vin/{vin}"
    print(f"Testing VIN Recall via Backend: {url}")
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            data = response.json()
            print("Response Summary:")
            print(f"Vehicle: {data.get('ModelYear')} {data.get('Make')} {data.get('Model')}")
            recalls = data.get('Recalls', [])
            print(f"Recalls Found: {len(recalls)}")
            for r in recalls:
                print(f" - {r.get('Component')}: {r.get('Summary')}")
        else:
            print(f"Error: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"Exception: {e}")

# Tesla VIN
check_recalls("5YJ3E1EA8LF123456")
