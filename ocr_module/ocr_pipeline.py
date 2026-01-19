from .pdf_text_extractor import extract_text_pdf
from .ocr_extractor import extract_text_ocr
from .text_cleaner import clean_text
from .extract_fields import extract_fields
import os


def run_ocr_pipeline(file_path):
    extension = os.path.splitext(file_path)[1].lower()

    if extension == ".pdf":
        raw_text = extract_text_pdf(file_path)
        method_used = "pdfplumber (PDF)"
    else:
        raw_text = extract_text_ocr(file_path)
        method_used = "EasyOCR (Image)"

    cleaned_text = clean_text(raw_text)

    extracted_data = extract_fields(cleaned_text)

    return {
    "method_used": method_used,
    "extracted_text": cleaned_text
    }

