import os
from pdf2image import convert_from_path
import pytesseract

# =========================================================
# 🔧 SYSTEM PATH CONFIGURATION (DO NOT CHANGE)
# =========================================================

# Absolute Poppler path (confirmed working)
POPPLER_PATH = r"C:\Users\shubh\OneDrive\Desktop\car_lease_ai\poppler\Library\bin"

# Absolute Tesseract path (required on Windows)
pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

print("🧰 Using Poppler from:", POPPLER_PATH)
print("🔎 Using Tesseract from:", pytesseract.pytesseract.tesseract_cmd)

# =========================================================
# 📄 OCR FUNCTION
# =========================================================

def extract_text(pdf_path: str) -> str:
    """
    Extract text from a PDF file using Poppler + Tesseract OCR
    """

    print("📄 OCR started for:", pdf_path)

    # Safety checks
    if not os.path.exists(pdf_path):
        raise FileNotFoundError(f"❌ PDF not found: {pdf_path}")

    if not os.path.exists(POPPLER_PATH):
        raise FileNotFoundError(f"❌ Poppler path not found: {POPPLER_PATH}")

    if not os.path.exists(pytesseract.pytesseract.tesseract_cmd):
        raise FileNotFoundError(
            f"❌ Tesseract not found: {pytesseract.pytesseract.tesseract_cmd}"
        )

    # Convert PDF → images
    pages = convert_from_path(pdf_path, poppler_path=POPPLER_PATH)
    print(f"🖼️ Total pages detected: {len(pages)}")

    full_text = ""

    for idx, page in enumerate(pages, start=1):
        print(f"🔍 OCR processing page {idx}...")
        text = pytesseract.image_to_string(page)
        full_text += text + "\n"

    print("✅ OCR completed successfully.")
    return full_text
