# Car Contract Analysis System

A simple web app that uses **OCR** and **Google Gemini** to extract and analyze car lease or loan contracts. Upload a PDF or image, see the extracted text, and get structured contract details plus a basic risk level.

## Project Overview

- **Backend:** Python with Flask  
- **OCR:** pytesseract, pdfplumber, Pillow (supports text PDFs, scanned PDFs, JPG, PNG)  
- **LLM:** Google Gemini API (gemini-pro) for contract analysis  
- **Frontend:** Single HTML page with CSS (no JavaScript framework)

When you upload a contract, the app:

1. Extracts all text using OCR and saves it to `output/extracted_text.txt`
2. Sends the text to Gemini to extract key terms (agreement type, monthly payment, APR, duration, mileage, penalties, early termination)
3. Shows the OCR text and structured analysis on the page, with a simple risk level (Low / Medium / High)

---

## How to Install Dependencies

1. Open a terminal in the project folder (e.g. `CAR CONTRACT`).
2. Create a virtual environment (recommended):
   ```bash
   python -m venv venv
   venv\Scripts\activate
   ```
3. Install the required packages:
   ```bash
   pip install -r requirements.txt
   ```
4. **Tesseract OCR:** Install Tesseract on Windows and keep the default path, or the app uses:
   `C:\Users\WIN\AppData\Local\Programs\Tesseract-OCR\tesseract.exe`  
   Download: https://github.com/UB-Mannheim/tesseract/wiki

---

## How to Set Your Gemini API Key

1. Get an API key from [Google AI Studio](https://makersuite.google.com/app/apikey) (Gemini).
2. Set it as an environment variable before running the app.

**Windows (PowerShell, current session):**
```powershell
$env:GEMINI_API_KEY = "your-api-key-here"
```

**Windows (Command Prompt):**
```cmd
set GEMINI_API_KEY=your-api-key-here
```

Replace `your-api-key-here` with your actual key. If you don’t set this, the app will show an error asking for the key.

---

## How to Run the Project

1. Set `GEMINI_API_KEY` as above.
2. From the **project root** (the folder that contains `backend`, `templates`, `static`), run:
   ```bash
   python backend/app.py
   ```
   Or go into the backend folder and run:
   ```bash
   cd backend
   python app.py
   ```
3. Open a browser and go to: **http://127.0.0.1:5000**
4. Use “Choose a file” to upload a contract (PDF, JPG, or PNG), then click **Analyze Contract**.

---

## Sample Output

- **OCR:** A long text block showing everything read from the document.  
- **Structured contract details (JSON-like):**  
  Agreement type, monthly payment, interest rate/APR, lease/loan duration, mileage limit, penalties, early termination clause.  
- **Risk insights:**  
  Risk level (Low / Medium / High) and a short explanation.

You can later extend this with comparison and negotiation features.
