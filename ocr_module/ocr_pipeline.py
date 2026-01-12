from .doc_type_detector import is_text_pdf
from .pdf_text_extractor import extract_text_pdf
from .ocr_extractor import extract_text_ocr
from .text_cleaner import clean_text


def run_ocr_pipeline(file_path):
    """
    Runs the complete OCR pipeline:
    - Detects document type
    - Extracts text using pdfplumber or OCR
    - Cleans the extracted text
    """

    if is_text_pdf(file_path):
        raw_text = extract_text_pdf(file_path)
        method_used = "pdfplumber (text-based PDF)"
    else:
        raw_text = extract_text_ocr(file_path)
        method_used = "EasyOCR (scanned PDF)"

    cleaned_text = clean_text(raw_text)

    return {
        "method_used": method_used,
        "extracted_text": cleaned_text
    }
