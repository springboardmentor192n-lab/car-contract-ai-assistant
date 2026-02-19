
import os
import shutil
import pytesseract
from pdf2image import convert_from_path

print("Checking Tesseract...")
tesseract_path = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
if os.path.exists(tesseract_path):
    print(f"✅ Tesseract found at {tesseract_path}")
    pytesseract.pytesseract.tesseract_cmd = tesseract_path
    try:
         print(f"Tesseract Version: {pytesseract.get_tesseract_version()}")
    except Exception as e:
         print(f"❌ Tesseract executable found but failed to run: {e}")
else:
    print(f"❌ Tesseract NOT found at {tesseract_path}")
    # Check PATH
    if shutil.which("tesseract"):
        print("✅ Tesseract found in PATH")
    else:
        print("❌ Tesseract NOT found in PATH")

print("\nChecking Poppler...")
try:
    # Try to verify poppler by running a dummy conversion (needs a pdf file, but we can just check info)
    # pdf2image wraps poppler tools (pdftoppm, pdftocairo)
    if shutil.which("pdftoppm"):
        print("✅ Poppler (pdftoppm) found in PATH")
    else:
        print("❌ Poppler (pdftoppm) NOT found in PATH. PDF conversion will fail.")
except Exception as e:
    print(f"Error checking Poppler: {e}")
