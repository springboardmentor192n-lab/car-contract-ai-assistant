
import requests
import json

def check_recalls(vin):
    url = f"https://api.nhtsa.gov/recalls/recallsByVin?vin={vin}&format=json"
    print(f"Testing URL: {url}")
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            print("Response:", json.dumps(response.json(), indent=2))
        else:
            print(f"Error: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"Exception: {e}")

# Tesla VIN from user
check_recalls("5YJ3E1EA8LF123456")
