
import requests
import os

def test_upload():
    url = "http://127.0.0.1:8001/contracts/upload"
    file_path = "uploads/test_pipeline.pdf"
    
    if not os.path.exists(file_path):
        print(f"File {file_path} does not exist. Run test_pipeline_v2.py first.")
        return

    print(f"Uploading {file_path} to {url}...")
    
    try:
        with open(file_path, "rb") as f:
            files = {"file": f}
            response = requests.post(url, files=files)
            
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("[SUCCESS] Upload successful.")
        else:
            print("[FAILURE] Upload failed.")
            
    except Exception as e:
        print(f"[FAILURE] Request failed: {e}")

if __name__ == "__main__":
    test_upload()
