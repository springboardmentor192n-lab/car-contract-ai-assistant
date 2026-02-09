 Car Contract Analysis System

A simple web app that uses **OCR** and **Google Gemini** to extract and analyze car lease or loan contracts. Upload a PDF or image, see the extracted text, and get structured contract details plus a basic risk level.

Project Overview

- **Backend:** Python with Flask  
- **OCR:** pytesseract, pdfplumber, Pillow (supports text PDFs, scanned PDFs, JPG, PNG)  
- **LLM:** Google Gemini API (gemini-pro) for contract analysis  
- **Frontend:** Single HTML page with CSS (no JavaScript framework)


Sample Output

- **OCR:** A long text block showing everything read from the document.  
- **Structured contract details (JSON-like):**  
  Agreement type, monthly payment, interest rate/APR, lease/loan duration, mileage limit, penalties, early termination clause.  
- **Risk insights:**  
  Risk level (Low / Medium / High) and a short explanation.

