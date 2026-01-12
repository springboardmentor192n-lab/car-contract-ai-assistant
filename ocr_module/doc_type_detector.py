import pdfplumber

def is_text_pdf(pdf_path):
    """
    Checks whether the PDF contains selectable text
    or is a scanned document.
    """
    with pdfplumber.open(pdf_path) as pdf:
        first_page = pdf.pages[0]
        text = first_page.extract_text()

        if text and len(text.strip()) > 50:
            return True
        return False
