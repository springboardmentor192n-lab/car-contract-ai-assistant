
import asyncio
import os
import json
from services.ocr_service import ocr_service
from services.llm_extraction_service import llm_service
from database import SessionLocal
import models

async def test_full_pipeline():
    image_path = r'c:\contract_anti\backend\uploads\01cff81c-fffc-4d1b-9fe5-1c81e6dc6dda_car.jpg'
    filename = 'car.jpg'
    
    print(f"1. Extracting text from {filename}...")
    text = await ocr_service.extract_text_from_file(image_path, filename)
    print(f"Extracted {len(text)} characters.")
    
    print("2. Running LLM extraction...")
    data = await llm_service.extract_data(text)
    print("Extraction Result:")
    print(json.dumps(data, indent=2))
    
    if "error" not in data:
        print("SUCCESS: Pipeline completed.")
    else:
        print(f"FAILURE: {data.get('error')}")

if __name__ == "__main__":
    asyncio.run(test_full_pipeline())
