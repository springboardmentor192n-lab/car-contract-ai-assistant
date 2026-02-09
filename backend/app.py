"""
Flask App - Car Contract Analysis System
Single route: / (GET = show upload form, POST = upload file, run OCR + Gemini, show results)
"""

import os
import sys

# So we can run from project root: python backend/app.py (Python will find ocr.py and llm.py in backend/)
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from flask import Flask, request, render_template
from werkzeug.utils import secure_filename

# Import our OCR and LLM modules
from ocr import extract_text
from llm import setup_gemini, analyze_contract

# --- Path setup: so the app finds templates/ and static/ even when run from backend/ ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(BASE_DIR)

# Folders for uploads and output (relative to project root)
UPLOAD_FOLDER = os.path.join(PROJECT_ROOT, "uploads")
OUTPUT_FOLDER = os.path.join(PROJECT_ROOT, "output")

# --- Paste your Gemini API key here (leave empty to use environment variable instead) ---
# Get your key from: https://makersuite.google.com/app/apikey
GEMINI_API_KEY = "AIzaSyBAhLyFEPBGBVB6VV2givIvBGvxLls3S2k"  # e.g. "AIzaSy..."

# Allowed file types for upload
ALLOWED_EXTENSIONS = {"pdf", "png", "jpg", "jpeg"}

# Create Flask app and point to project folders
app = Flask(
    __name__,
    template_folder=os.path.join(PROJECT_ROOT, "templates"),
    static_folder=os.path.join(PROJECT_ROOT, "static"),
)
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER
app.config["MAX_CONTENT_LENGTH"] = 16 * 1024 * 1024  # Max 16 MB file size
app.secret_key = "car-contract-demo-secret-key"


def allowed_file(filename: str) -> bool:
    """Check if the uploaded file has an allowed extension."""
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route("/", methods=["GET", "POST"])
def index():
    """
    Single page: upload contract, run OCR and Gemini, show results.
    GET  -> Show the upload form.
    POST -> Handle file upload, run OCR, run Gemini, show OCR text + analysis.
    """
    if request.method == "GET":
        # Just show the upload page (no results yet)
        return render_template("index.html", ocr_text=None, analysis=None, error=None)

    # --- POST: User submitted a file ---
    ocr_text = None
    analysis = None
    error = None

    # Check if a file was actually uploaded
    if "file" not in request.files:
        return render_template(
            "index.html",
            ocr_text=None,
            analysis=None,
            error="No file was selected. Please choose a PDF or image file.",
        )

    file = request.files["file"]
    if file.filename == "":
        return render_template(
            "index.html",
            ocr_text=None,
            analysis=None,
            error="No file was selected. Please choose a PDF or image file.",
        )

    if not allowed_file(file.filename):
        return render_template(
            "index.html",
            ocr_text=None,
            analysis=None,
            error="Invalid file type. Please upload a PDF, JPG, or PNG file.",
        )

    try:
        # Create uploads folder if it doesn't exist
        os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)
        # Save the file with a safe filename
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config["UPLOAD_FOLDER"], filename)
        file.save(filepath)

        # Step 1: Run OCR and get extracted text
        ocr_text = extract_text(filepath, OUTPUT_FOLDER)

        # Step 2: Get Gemini API key (from environment variable or from GEMINI_API_KEY above)
        api_key = os.environ.get("GEMINI_API_KEY") or GEMINI_API_KEY
        if not api_key:
            return render_template(
                "index.html",
                ocr_text=ocr_text,
                analysis=None,
                error="Gemini API key not set. Paste your key in backend/app.py (GEMINI_API_KEY) or set the GEMINI_API_KEY environment variable.",
            )

        # Configure Gemini and run analysis
        setup_gemini(api_key)
        analysis = analyze_contract(ocr_text)

        # Show results (OCR text + Gemini analysis)
        return render_template(
            "index.html",
            ocr_text=ocr_text,
            analysis=analysis,
            error=None,
        )

    except ValueError as e:
        # e.g. unsupported file type from our code
        return render_template(
            "index.html",
            ocr_text=None,
            analysis=None,
            error=f"Error: {str(e)}",
        )
    except Exception as e:
        # Catch any other error (e.g. Tesseract not installed, PDF broken)
        return render_template(
            "index.html",
            ocr_text=ocr_text if ocr_text is not None else None,
            analysis=analysis if analysis is not None else None,
            error=f"Something went wrong: {str(e)}",
        )


# Run the app when this file is executed directly (e.g. python app.py)
if __name__ == "__main__":
    # Ensure upload and output folders exist
    os.makedirs(UPLOAD_FOLDER, exist_ok=True)
    os.makedirs(OUTPUT_FOLDER, exist_ok=True)
    # Run Flask (use 0.0.0.0 to access from other devices on your network if needed)
    app.run(debug=True, port=5000)
