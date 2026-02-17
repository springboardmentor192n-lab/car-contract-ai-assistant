import easyocr
import fitz  # PyMuPDF
import numpy as np
from PIL import Image

reader = easyocr.Reader(['en'], gpu=False)


def extract_text_from_image(image_path: str) -> str:
    """Extract text from image files using OCR"""
    image = Image.open(image_path)
    image_np = np.array(image)
    results = reader.readtext(image_np, detail=0)
    return " ".join(results)


def extract_text_from_pdf(pdf_path: str) -> str:
    """
    Extract text from PDF using PyMuPDF.
    First tries direct text extraction (for text-based PDFs).
    Falls back to OCR if the PDF is scanned/image-based.
    """
    doc = fitz.open(pdf_path)
    text = []
    
    for page_num in range(len(doc)):
        page = doc[page_num]
        
        # Try direct text extraction first (faster for text-based PDFs)
        page_text = page.get_text()
        
        # If page has little/no text, it's likely a scanned image - use OCR
        if len(page_text.strip()) < 50:
            # Convert page to image for OCR
            pix = page.get_pixmap(matrix=fitz.Matrix(2, 2))  # 2x zoom for better OCR
            img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
            img_np = np.array(img)
            
            # Use EasyOCR for scanned pages
            ocr_results = reader.readtext(img_np, detail=0)
            text.extend(ocr_results)
        else:
            # Use directly extracted text
            text.append(page_text)
    
    doc.close()
    return " ".join(text)


def extract_text(file_path: str) -> str:
    """Main entry point for text extraction from files"""
    if file_path.lower().endswith(".pdf"):
        return extract_text_from_pdf(file_path)
    else:
        return extract_text_from_image(file_path)
