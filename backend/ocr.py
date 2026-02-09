"""
OCR Module - Extracts text from car contract documents.
Supports: Text PDFs, Scanned PDFs, Images (JPG, PNG)
Uses: pytesseract, pdfplumber, Pillow
"""

import os
import pytesseract
import pdfplumber
from PIL import Image

# --- IMPORTANT: Set Tesseract path for Windows ---
# This tells Python where to find the Tesseract OCR program on your PC
pytesseract.pytesseract.tesseract_cmd = r"C:\Users\WIN\AppData\Local\Programs\Tesseract-OCR\tesseract.exe"


def extract_text_from_image(image_path: str) -> str:
    """
    Extract text from an image file (JPG, PNG) using Tesseract OCR.
    Tesseract "reads" the image and returns the text it finds.
    """
    # Open the image using Pillow
    img = Image.open(image_path)
    # Run Tesseract OCR on the image
    text = pytesseract.image_to_string(img)
    return text.strip()


def extract_text_from_pdf(pdf_path: str) -> str:
    """
    Extract text from a PDF file.
    First tries pdfplumber (good for text-based PDFs).
    If little or no text is found, treats PDF as scanned and uses Tesseract on each page.
    """
    all_text = []

    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            # Try to get text directly from the page (works for digital/text PDFs)
            page_text = page.extract_text()
            if page_text and len(page_text.strip()) > 50:
                # We got enough text from this page
                all_text.append(page_text)
            else:
                # Page might be a scanned image - convert to image and use OCR
                # pdfplumber can render page as image
                img = page.to_image(resolution=150)
                pil_image = img.original
                page_text = pytesseract.image_to_string(pil_image)
                all_text.append(page_text)

    return "\n\n".join(all_text).strip()


def extract_text(file_path: str, output_dir: str) -> str:
    """
    Main function: Detects file type and extracts all text.
    Saves the extracted text to output/extracted_text.txt and returns it.
    """
    # Get file extension to decide how to process
    _, ext = os.path.splitext(file_path)
    ext = ext.lower()

    if ext == ".pdf":
        extracted = extract_text_from_pdf(file_path)
    elif ext in (".jpg", ".jpeg", ".png"):
        extracted = extract_text_from_image(file_path)
    else:
        raise ValueError(f"Unsupported file type: {ext}. Use PDF, JPG, or PNG.")

    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)
    output_file = os.path.join(output_dir, "extracted_text.txt")

    # Save extracted text to file (as required)
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(extracted)

    return extracted
