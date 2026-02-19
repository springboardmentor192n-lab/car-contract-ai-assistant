
import pytesseract
from PIL import Image
import os
import json

# Manual config for the test
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

image_path = r'c:\contract_anti\backend\uploads\01cff81c-fffc-4d1b-9fe5-1c81e6dc6dda_car.jpg'

try:
    print(f"Testing OCR on {image_path}...")
    image = Image.open(image_path)
    text = pytesseract.image_to_string(image)
    print("OCR Content (first 50 chars):")
    print(text[:50])
    
    if len(text.strip()) > 0:
        print("SUCCESS: OCR extracted text.")
    else:
        print("FAILURE: OCR returned no text.")
except Exception as e:
    print(f"OCR ERROR: {e}")
