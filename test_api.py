import requests
import os

# Configuration
URL = "http://127.0.0.1:8000/analyze-pdf"
PDF_PATH = os.path.join("data", "raw_pdfs", "sample.pdf")

# Check if file exists, if not try another one
if not os.path.exists(PDF_PATH):
    PDF_PATH = os.path.join("backend", "uploads", "Mercedes_C200_Ultra_Realistic_Lease_Agreement.pdf")

if not os.path.exists(PDF_PATH):
    print(f"Error: Could not find a PDF to test at {PDF_PATH}")
    exit(1)

print(f"Testing API with file: {PDF_PATH}")

try:
    with open(PDF_PATH, "rb") as f:
        files = {"file": (os.path.basename(PDF_PATH), f, "application/pdf")}
        response = requests.post(URL, files=files)

    if response.status_code == 200:
        data = response.json()
        print("✅ API Request Successful")
        print(f"Filename: {data.get('filename')}")
        print(f"Fairness Score: {data.get('fairness')}")
        print(f"AI Summary: {data.get('ai_summary')[:100]}...")
        
        price_est = data.get("price_estimation")
        if price_est:
            print("✅ Price Estimation Data Found")
            print(f"Min Price: {price_est.get('estimated_price_min')}")
            print(f"Max Price: {price_est.get('estimated_price_max')}")
        else:
            print("⚠️ No Price Estimation returned (expected if VIN not found or not provided)")
            
    else:
        print(f"❌ API Request Failed: {response.status_code}")
        print(response.text)

except Exception as e:
    print(f"❌ Error: {e}")
