from fastapi import FastAPI, UploadFile, File
from fastapi import FastAPI, UploadFile, File
import os, shutil, sys, re, joblib


# -------------------------------------------------
# Path setup
# -------------------------------------------------
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
BACKEND_DIR = os.path.join(BASE_DIR, "backend")
sys.path.insert(0, BASE_DIR)
sys.path.insert(0, BACKEND_DIR)


# -------------------------------------------------
# Project imports
# -------------------------------------------------
from ocr.text import extract_text
from .llm_service import generate_summary, negotiation_chat
from .fairness import calculate_fairness_score
from .vin_service import get_vehicle_details
from .price_estimation import estimate_vehicle_price


# -----------------------------
# App init
# -----------------------------
app = FastAPI(title="Car Lease AI Assistant")

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------------------------------------
# Uploads directory
# -------------------------------------------------
UPLOAD_DIR = os.path.join(BASE_DIR, "backend", "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)

# -------------------------------------------------
# Load ML model (classifier pipeline)
# -------------------------------------------------
MODEL_PATH = os.path.join(BASE_DIR, "models", "clause_classifier.pkl")

print("📦 Loading clause classification model...")
model = joblib.load(MODEL_PATH)
print("✅ Model loaded successfully")

# -------------------------------------------------
# Helpers
# -------------------------------------------------
def split_into_sentences(text: str):
    sentences = re.split(r'(?<=[.!?])\s+', text)
    return [s.strip() for s in sentences if len(s.strip()) > 5]

# =================================================
# 🟢 Health Check
# =================================================
@app.get("/")
def root():
    return {"status": "Car Lease AI Backend is running"}

# =================================================
# 📄 ANALYZE PDF (MAIN PIPELINE)
# =================================================
@app.post("/analyze-pdf")
async def analyze_pdf(
    file: UploadFile = File(...),
    vin: str | None = None
):
    # -----------------------------
    # 1️⃣ Save PDF
    # -----------------------------
    pdf_path = os.path.join(UPLOAD_DIR, file.filename)
    with open(pdf_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # -----------------------------
    # 2️⃣ OCR
    # -----------------------------
    text = extract_text(pdf_path)
    sentences = split_into_sentences(text)

    if not sentences:
        return {"error": "No readable text found in PDF"}

    # -----------------------------
    # 2.5️⃣ Extract VIN from text if not provided
    # -----------------------------
    if not vin:
        # Regex for standard 17-char VIN (excluding I, O, Q)
        vin_match = re.search(r'\b[A-HJ-NPR-Z0-9]{17}\b', text)
        if vin_match:
            vin = vin_match.group(0)
            print(f"🚗 Extracted VIN from PDF: {vin}")

    # -----------------------------
    # 3️⃣ ML Clause Classification
    # -----------------------------
    predictions = model.predict(sentences)

    clauses = {}
    for sent, label in zip(sentences, predictions):
        clauses.setdefault(label, []).append(sent)

    # -----------------------------
    # 4️⃣ Fairness Score
    # -----------------------------
    fairness = calculate_fairness_score(clauses)

    # -----------------------------
    # 5️⃣ & 5.5️⃣ Parallel LLM Calls
    # -----------------------------
    import asyncio
    from .llm_service import generate_summary, extract_contract_details

    # Run both LLM tasks concurrently to save time
    ai_summary, contract_details = await asyncio.gather(
        generate_summary(clauses),
        extract_contract_details(clauses)
    )

    # -----------------------------
    # 6️⃣ VIN + Price Estimation (optional)
    # -----------------------------
    vehicle_info = None
    price_estimation = None

    if vin:
        vehicle_info = get_vehicle_details(vin)

        if isinstance(vehicle_info, dict) and "Make" in vehicle_info and "ModelYear" in vehicle_info:
            price_estimation = estimate_vehicle_price(vehicle_info)

    # -----------------------------
    # Final Response
    # -----------------------------
    return {
        "filename": file.filename,
        "total_sentences": len(sentences),
        "clauses": clauses,
        "fairness": fairness,
        "contract_details": contract_details,
        "vehicle_info": vehicle_info,
        "price_estimation": price_estimation,
        "ai_summary": ai_summary
    }

# =================================================
# 🤝 NEGOTIATION CHATBOT
# =================================================
@app.post("/negotiate")
async def negotiate(payload: dict):
    """
    payload example:
    {
      "clauses": {...},
      "question": "What should I negotiate?"
    }
    """

    clauses = payload.get("clauses")
    question = payload.get("question")

    if not clauses or not question:
        return {"error": "Both clauses and question are required"}

    result = await negotiation_chat(clauses, question)

    # If result is a string (error case from older LLM service version), handle gracefully
    if isinstance(result, str):
         return {
            "question": question,
            "negotiation_advice": result,
            "email_draft": None,
            "suggestions": []
        }

    return {
        "question": question,
        "negotiation_advice": result.get("advice"),
        "email_draft": result.get("email_draft"),
        "suggestions": result.get("suggestions", [])
    }

# =================================================
# 🚗 VIN API (Standalone)
# =================================================
@app.get("/vin/{vin}")
def decode_vin(vin: str):
    return get_vehicle_details(vin)

# =================================================
# 💰 PRICE ESTIMATION (Standalone)
# =================================================
@app.post("/price-estimate")
def price_estimate(vehicle: dict):
    return estimate_vehicle_price(vehicle)
