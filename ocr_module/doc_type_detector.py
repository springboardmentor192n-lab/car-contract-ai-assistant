import pdfplumber
import os

def is_text_pdf(file_path):
    """
    Returns True if the file is a text-based PDF.
    Returns False for scanned PDFs or image files.
    """

    # If file is NOT a PDF, skip pdfplumber
    if not file_path.lower().endswith(".pdf"):
        return False

    try:
        with pdfplumber.open(file_path) as pdf:
            first_page = pdf.pages[0]
            text = first_page.extract_text()

            if text and len(text.strip()) > 50:
                return True
            return False
    except Exception:
        return False
