import pdfplumber

def extract_text_pdf(pdf_path):
    """
    Extracts text from text-based PDFs using pdfplumber.
    """
    text = ""

    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            page_text = page.extract_text()
            if page_text:
                text += page_text + "\n"

    return text
