
import requests
import os
import time
import json

def test_endpoint_and_poll():
    base_url = "http://127.0.0.1:8001/contracts"
    upload_url = f"{base_url}/upload"
    file_path = "uploads/test_pipeline.pdf"
    
    if not os.path.exists(file_path):
        print(f"File {file_path} does not exist. Run test_pipeline_v2.py first.")
        # Create dummy if missing
        with open(file_path, "wb") as f:
            f.write(b"%PDF-1.4 dummy content")
            
    print(f"Uploading {file_path} to {upload_url}...")
    
    try:
        with open(file_path, "rb") as f:
            files = {"file": f}
            response = requests.post(upload_url, files=files)
            
        print(f"Upload Status Code: {response.status_code}")
        
        if response.status_code != 200:
            print(f"[FAILURE] Upload failed: {response.text}")
            return
            
        data = response.json()
        contract_id = data.get("id")
        print(f"Contract ID: {contract_id}, Status: {data.get('status')}")
        
        # Poll for status
        for i in range(20): # Try for 20 seconds
            print(f"Polling attempt {i+1}...")
            time.sleep(1)
            
            resp = requests.get(f"{base_url}/{contract_id}")
            if resp.status_code != 200:
                print(f"[WARNING] Poll failed: {resp.status_code}")
                continue
                
            contract = resp.json()
            status = contract.get("status")
            print(f"Current Status: {status}")
            
            if status == "completed":
                print("[SUCCESS] Contract processing completed!")
                print(json.dumps(contract.get("sla"), indent=2))
                return
            elif status == "failed":
                print("[FAILURE] Contract processing FAILED.")
                return
                
        print("[TIMEOUT] Contract processing timed out.")

            
    except Exception as e:
        print(f"[FAILURE] Test failed: {e}")

if __name__ == "__main__":
    test_endpoint_and_poll()
