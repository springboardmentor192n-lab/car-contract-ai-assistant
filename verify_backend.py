import requests
import json
import time

BASE_URL = "http://127.0.0.1:8000"

def test_negotiation():
    print("\n--- Testing Negotiation Chat ---")
    url = f"{BASE_URL}/negotiate"
    payload = {
        "clauses": {
            "money_factor": ["The money factor is 0.0025"],
            "disposition_fee": ["Disposition fee is $595"]
        },
        "question": "Is this money factor high?"
    }
    
    try:
        start = time.time()
        response = requests.post(url, json=payload)
        duration = time.time() - start
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Success ({duration:.2f}s)")
            print(json.dumps(data, indent=2))
        else:
            print(f"❌ Failed: {response.status_code}")
            print(response.text)
    except Exception as e:
        print(f"❌ Error: {e}")

def test_vin_endpoint():
    print("\n--- Testing VIN Endpoint ---")
    # Using a sample VIN (Tesla Model 3 from recall test)
    vin = "5YJ3E1EA8LF123456" 
    url = f"{BASE_URL}/vin/{vin}"
    
    try:
        start = time.time()
        response = requests.get(url)
        duration = time.time() - start
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Success ({duration:.2f}s)")
            # Print a summary to avoid clutter
            print(f"Make: {data.get('Make')}")
            print(f"Model: {data.get('Model')}")
            print(f"Recalls Found: {len(data.get('Recalls', []))}")
            if data.get('Recalls'):
                print(f"Sample Recall: {data['Recalls'][0]['Summary']}")
        else:
            print(f"❌ Failed: {response.status_code}")
            print(response.text)
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    print(f"Testing Backend at {BASE_URL}")
    test_negotiation()
    test_vin_endpoint()
