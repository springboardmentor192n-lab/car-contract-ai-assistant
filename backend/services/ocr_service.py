
import pytesseract
from PIL import Image

import io
import os

class OCRService:
    def __init__(self):
        # Configure Tesseract path for Windows
        tesseract_path = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
        if os.path.exists(tesseract_path):
            pytesseract.pytesseract.tesseract_cmd = tesseract_path
            print(f"[OCR] Tesseract configured at {tesseract_path}")
        else:
            print("WARNING: Tesseract executable not found at standard path.")
            
        # Add user-provided Poppler path (if exists)
        poppler_path = r'C:\poppler-25.12.0\Library\bin'
        if os.path.exists(poppler_path):
             os.environ["PATH"] += os.pathsep + poppler_path
             print(f"[OCR] Added Poppler to PATH: {poppler_path}")
             
    def log_debug(self, msg):
        with open("debug_ocr.log", "a", encoding='utf-8') as f:
            from datetime import datetime
            f.write(f"[{datetime.now()}] {msg}\n")

    async def extract_text_from_file(self, file_path: str, filename: str) -> str:
        ext = filename.split('.')[-1].lower()
        
        if ext == 'pdf':
            text = self._extract_from_pdf(file_path)
            self.log_debug(f"Extracted {len(text)} chars from PDF: {filename}")
            return text
        elif ext in ['jpg', 'jpeg', 'png', 'bmp']:
            return self._extract_from_image(file_path)
        else:
            raise ValueError(f"Unsupported file format: {ext}")

    def _extract_from_image(self, image_path: str) -> str:
        try:
            image = Image.open(image_path)
            text = pytesseract.image_to_string(image)
            return text
        except Exception as e:
            print(f"Error extracting from image: {e}")
            return ""

    def _extract_from_pdf(self, pdf_path: str) -> str:
        text = ""
        try:
            import fitz  # PyMuPDF
            doc = fitz.open(pdf_path)
            
            # 1. Try direct text extraction (fast)
            for page in doc:
                text += page.get_text() + "\n"
            
            # If significant text found, return it
            if len(text.strip()) > 50:
                print("Extracted text directly from PDF (PyMuPDF).")
                return text
            
            print("PDF seems to be scanned (little text found). Falling back to OCR...")
            
            # 2. Fallback to OCR using PyMuPDF to render images (No Poppler needed)
            full_text = ""
            for page in doc:
                pix = page.get_pixmap()
                img_data = pix.tobytes("png")
                image = Image.open(io.BytesIO(img_data))
                full_text += pytesseract.image_to_string(image) + "\n"
                
            return full_text

        except Exception as e:
            print(f"Error extracting from PDF: {e}")
            if text: return text # Return partial text if available
            return ""

ocr_service = OCRService()
