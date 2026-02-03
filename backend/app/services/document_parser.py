# backend/app/services/document_parser.py
import PyPDF2
from docx import Document
import pytesseract
from PIL import Image
import io
import re
from typing import Dict, List


class DocumentParser:
    def __init__(self):
        pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'  # Windows

    def parse_document(self, file_bytes: bytes, filename: str) -> Dict:
        """Parse PDF, DOCX, or Image"""
        file_ext = filename.split('.')[-1].lower()

        if file_ext == 'pdf':
            text = self._parse_pdf(file_bytes)
        elif file_ext == 'docx':
            text = self._parse_docx(file_bytes)
        elif file_ext in ['jpg', 'jpeg', 'png']:
            text = self._parse_image(file_bytes)
        else:
            text = file_bytes.decode('utf-8', errors='ignore')

        # Quick SLA field extraction
        extracted = self._quick_extract(text)

        return {
            "text": text[:5000],  # Limit for demo
            "extracted_fields": extracted,
            "file_type": file_ext
        }

    def _parse_pdf(self, file_bytes: bytes) -> str:
        """Extract text from PDF"""
        text = ""
        try:
            pdf_reader = PyPDF2.PdfReader(io.BytesIO(file_bytes))
            for page in pdf_reader.pages:
                text += page.extract_text() + "\n"
        except:
            text = "PDF parsing failed"
        return text

    def _parse_docx(self, file_bytes: bytes) -> str:
        """Extract text from DOCX"""
        doc = Document(io.BytesIO(file_bytes))
        return "\n".join([para.text for para in doc.paragraphs])

    def _parse_image(self, file_bytes: bytes) -> str:
        """Extract text from image using OCR"""
        try:
            image = Image.open(io.BytesIO(file_bytes))
            text = pytesseract.image_to_string(image)
            return text
        except:
            return "OCR failed - install Tesseract OCR"

    def _quick_extract(self, text: str) -> Dict:
        """Quick regex extraction for key terms"""
        patterns = {
            "interest_rate": r"(?:interest rate|APR)[:\s]*([\d\.]+%)",
            "monthly_payment": r"(?:monthly payment|installment)[:\s]*\$?([\d,]+\.?\d*)",
            "lease_term": r"(?:term|duration)[:\s]*(\d+)\s*(?:months|years)",
            "down_payment": r"(?:down payment|deposit)[:\s]*\$?([\d,]+\.?\d*)",
            "mileage": r"(?:mileage|annual mileage)[:\s]*([\d,]+)",
        }

        extracted = {}
        for key, pattern in patterns.items():
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                extracted[key] = match.group(1)

        return extracted