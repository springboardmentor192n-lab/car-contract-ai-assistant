
import requests
import time

URL = "http://127.0.0.1:8001/contracts"

print(f"Testing GET {URL}")
start = time.time()
try:
    response = requests.get(URL, timeout=30)
    end = time.time()
    print(f"Status Code: {response.status_code}")
    print(f"Time Taken: {end - start:.4f} seconds")
    print(f"Response Length: {len(response.content)}")
    if response.status_code == 200:
        data = response.json()
        print(f"Number of contracts: {len(data)}")
    else:
        print(response.text)
except Exception as e:
    print(f"Error: {e}")
