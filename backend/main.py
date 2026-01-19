from fastapi import FastAPI, File, UploadFile, HTTPException
from typing import Dict, Any, List
import pytesseract
import tempfile
import shutil
from PIL import Image
import re
import os
import requests
from contextlib import asynccontextmanager
from transformers import pipeline
from dotenv import load_dotenv

load_dotenv()

# --- Model and App State ---

# This dictionary will hold the loaded model.
ml_models = {}

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Load the NLP model on startup
    print("Loading sentiment analysis model...")
    # Using a lightweight model for sentiment analysis.
    # We'll interpret "NEGATIVE" sentiment as a potential risk.
    ml_models["sentiment_analyzer"] = pipeline(
        "sentiment-analysis", model="distilbert-base-uncased-finetuned-sst-2-english"
    )
    print("Model loaded successfully.")
    yield
    # Clean up the model on shutdown
    ml_models.clear()
    print("Model cleaned up.")


# Create a FastAPI instance with the lifespan manager
app = FastAPI(
    title="AI-Powered AutoFinance Guardian API",
    description="API for analyzing car lease/loan contracts, providing negotiation assistance, and vehicle data.",
    version="0.1.0",
    lifespan=lifespan,
)

# --- Helper Functions ---

def extract_financial_terms(text: str) -> Dict[str, Any]:
    """Uses regular expressions to find common financial terms."""
    patterns = {
        "annual_percentage_rate_apr": r"(\bAPR\b|Annual Percentage Rate)\s*[:\-]?\s*(\d{1,2}\.\d{1,4}?)%?",
        "monthly_payment": r"(Monthly Payment|Monthly Rent)\s*[:\-]?\s*\$?(\d{1,4}\.\d{2})",
        "loan_term": r"(\bTerm\b|Number of Payments)\s*[:\-]?\s*(\d{2,3})",
        "amount_financed": r"(Amount Financed)\s*[:\-]?\s*\$?([\d,]+\.\d{2})",
        "mileage_allowance": r"(Mileage Allowance|Annual Mileage)\s*[:\-]?\s*([\d,]+)",
    }
    found_terms = {}
    for term, pattern in patterns.items():
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            found_terms[term] = match.group(match.lastindex).strip()
    return found_terms

def analyze_text_for_risks(text: str, model: pipeline) -> List[str]:
    """Uses a sentiment analysis model to flag potentially risky sentences."""
    # Simple sentence splitting. This could be improved with a proper NLP library like NLTK.
    sentences = [s.strip() for s in text.split('.') if len(s.strip()) > 20]
    
    risky_clauses = []
    try:
        results = model(sentences)
        for i, result in enumerate(results):
            # If the sentiment is negative, we flag it as a potential risk.
            if result['label'] == 'NEGATIVE' and result['score'] > 0.8:
                risky_clauses.append(sentences[i])
    except Exception as e:
        print(f"Error during sentiment analysis: {e}")

    return risky_clauses

# --- API Endpoints ---

@app.get("/", tags=["General"])
async def read_root() -> Dict[str, str]:
    """Root endpoint that returns a welcome message."""
    return {"message": "Welcome to the AI-Powered AutoFinance Guardian API!"}

@app.post("/analyze_contract", tags=["Contract Analysis"])
async def analyze_contract(file: UploadFile = File(...)) -> Dict[str, Any]:
    """
    Upload a contract image, performs OCR, extracts financial terms,
    and analyzes the text for potential risks.
    """
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail=f"File provided is not an image. Content-Type: {file.content_type}")

    temp_dir = tempfile.mkdtemp()
    temp_file_path = os.path.join(temp_dir, file.filename)

    try:
        with open(temp_file_path, "wb") as f:
            shutil.copyfileobj(file.file, f)
        
        extracted_text = pytesseract.image_to_string(Image.open(temp_file_path))
        extracted_terms = extract_financial_terms(extracted_text)
        
        # Get the loaded model and analyze for risks
        sentiment_model = ml_models.get("sentiment_analyzer")
        if sentiment_model:
            potential_risks = analyze_text_for_risks(extracted_text, sentiment_model)
        else:
            potential_risks = ["Sentiment model not available."]

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error during file processing: {e}")
    finally:
        shutil.rmtree(temp_dir)
        file.file.close()

    return {
        "filename": file.filename,
        "content_type": file.content_type,
        "extracted_terms": extracted_terms,
        "potential_risks": potential_risks,
        "raw_text": extracted_text,
    }

@app.get("/vin_lookup/{vin}", tags=["Vehicle Data"])
async def vin_lookup(vin: str) -> Dict[str, Any]:
    """
    Endpoint to look up vehicle information using its VIN from the NHTSA API.
    """
    if len(vin) != 17 or not vin.isalnum():
        raise HTTPException(status_code=400, detail="Invalid VIN format. Must be 17 alphanumeric characters.")

    api_url = f"https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues/{vin}?format=json"

    try:
        response = requests.get(api_url, timeout=10)
        response.raise_for_status()  # Raise an exception for bad status codes
        data = response.json()

        results = data.get("Results", [])
        if not results:
            raise HTTPException(status_code=404, detail="VIN not found or no data available.")

        # The API returns a list, we'll take the first result.
        vin_info = results[0]
        
        # Filter for relevant, non-empty fields
        relevant_details = {
            "Make": vin_info.get("Make"),
            "Model": vin_info.get("Model"),
            "ModelYear": vin_info.get("ModelYear"),
            "VehicleType": vin_info.get("VehicleType"),
            "BodyClass": vin_info.get("BodyClass"),
            "EngineCylinders": vin_info.get("EngineCylinders"),
            "FuelTypePrimary": vin_info.get("FuelTypePrimary"),
            "PlantCity": vin_info.get("PlantCity"),
            "PlantCountry": vin_info.get("PlantCountry"),
            "ErrorCode": vin_info.get("ErrorCode"),
        }
        
        # Check if the VIN decode was successful
        if relevant_details["ErrorCode"] != "0":
            error_msg = vin_info.get('ErrorText', 'Unknown error')
            raise HTTPException(status_code=400, detail=f"Error decoding VIN: {error_msg}")

        return {"vin": vin, "vehicle_details": relevant_details}

    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=503, detail=f"Could not connect to the vehicle data service: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An unexpected error occurred: {e}")

@app.get("/market_data/{make}/{model}/{year}", tags=["Market Data"])
async def get_market_data(make: str, model: str, year: int) -> Dict[str, Any]:
    """
    Endpoint to get a national average auto loan interest rate from the FRED API.
    Note: This provides a general market benchmark, not a rate specific to the
    make, model, or year.
    """
    fred_api_key = os.getenv("FRED_API_KEY")
    if not fred_api_key or fred_api_key == "YOUR_API_KEY_HERE":
        raise HTTPException(
            status_code=401,
            detail="FRED API key not found. Please set it in your .env file."
        )

    # Series ID for "Commercial bank interest rate on new auto loans, 60 month"
    series_id = "RIFLPBCIANM60NM"
    
    # FRED API parameters
    params = {
        "series_id": series_id,
        "api_key": fred_api_key,
        "file_type": "json",
        "sort_order": "desc",
        "limit": 1
    }

    api_url = "https://api.stlouisfed.org/fred/series/observations"

    try:
        response = requests.get(api_url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        observations = data.get("observations")
        if not observations:
            raise HTTPException(status_code=404, detail="No observations found for the series.")

        latest_rate = observations[0].get("value")
        rate_date = observations[0].get("date")

        # FRED may return '.' for missing data
        if latest_rate == ".":
             raise HTTPException(status_code=404, detail="Latest rate data is not available.")

        return {
            "vehicle": f"{year} {make} {model}",
            "market_benchmark_source": "FRED API (National Average)",
            "series_name": "Commercial Bank Interest Rate on New Auto Loans, 60 Month",
            "average_apr": f"{latest_rate}%",
            "last_updated": rate_date,
            "price_range": "N/A (not available from this source)"
        }

    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=503, detail=f"Could not connect to the FRED API service: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An unexpected error occurred: {e}")

@app.post("/export_report", tags=["Reporting"])
async def export_report(analysis_data: Dict[str, Any]) -> Dict[str, str]:
    """Endpoint to export an analysis report to PDF."""
    return {"status": "PDF export pending implementation."}

